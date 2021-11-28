//
//  DownloadDataSource.swift
//  DataSource
//
//  Created by Yuki Okudera on 2021/11/23.
//

import Foundation

public enum DownloadDataSourceProvider {
    public static func provide() -> DownloadDataSource {
        return DownloadDataSourceImpl(localFileDataSource: LocalFileDataSourceProvider.provide())
    }
}

public protocol DownloadDataSource: AnyObject {
    func execute(urls: [URL])
}

final class DownloadDataSourceImpl: NSObject, DownloadDataSource {

    let localFileDataSource: LocalFileDataSource

    init(localFileDataSource: LocalFileDataSource) {
        self.localFileDataSource = localFileDataSource
    }

    func execute(urls: [URL]) {
        let sessionIdentifier = UUID().uuidString
        let configuration = BackgroundConfigurationGenerator.generate(identifier: sessionIdentifier)
        let session = URLSession(configuration: configuration, delegate: self, delegateQueue: .main)

        let tuple: [(context: DownloadContext, downloadTask: URLSessionDownloadTask)] = urls.map {
            let downloadTask = session.downloadTask(with: $0)
            downloadTask.earliestBeginDate = Date().addingTimeInterval(5)
            downloadTask.countOfBytesClientExpectsToSend = 250
            downloadTask.countOfBytesClientExpectsToReceive = 10 * 1024

            let destinationUrl = localFileDataSource.downloadDataDirectory.appendingPathComponent($0.lastPathComponent)
            let downloadContext = DownloadContext(sessionId: sessionIdentifier, taskId: downloadTask.taskIdentifier, filePath: destinationUrl.path)
            return (context: downloadContext, downloadTask: downloadTask)
        }
        DownloadGroupStore.shared.addTargetContexts(downloadContexts: tuple.map { $0.context })
        tuple.forEach {
            $0.downloadTask.resume()
        }
    }
}

extension DownloadDataSourceImpl: URLSessionDelegate {

    func urlSession(_ session: URLSession, didBecomeInvalidWithError error: Error?) {
        log("didBecomeInvalidWithError: \(String(describing: error))")
    }

    func urlSessionDidFinishEvents(forBackgroundURLSession session: URLSession) {
        log("urlSessionDidFinishEvents")
        NotificationCenter.default.post(name: .downloadCompleted, object: nil)
    }
}

extension DownloadDataSourceImpl: URLSessionDownloadDelegate {

    func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didFinishDownloadingTo location: URL) {
        log("didFinishDownloadingTo", location)

        guard let downloadContext = DownloadGroupStore.shared.specificDownloadContext(
            sessionId: session.configuration.identifier,
            taskId: downloadTask.taskIdentifier
        ) else {
            return
        }
        DownloadGroupStore.shared.addFinishedContext(downloadContext: downloadContext)

        log("PROGRESS", DownloadGroupStore.shared.progress)
        localFileDataSource.writeFile(downloadContext: downloadContext, from: location)
    }

    // Called only in foreground.
    func urlSession(
        _ session: URLSession,
        downloadTask: URLSessionDownloadTask,
        didWriteData bytesWritten: Int64,
        totalBytesWritten: Int64,
        totalBytesExpectedToWrite: Int64
    ) {
        guard let downloadContext = DownloadGroupStore.shared.specificDownloadContext(
            sessionId: session.configuration.identifier,
            taskId: downloadTask.taskIdentifier
        ) else {
            return
        }
        let percentDownloaded = totalBytesWritten / totalBytesExpectedToWrite
        log("downloadContext", downloadContext)
        log("totalBytesWritten", totalBytesWritten, "totalBytesExpectedToWrite", totalBytesExpectedToWrite, "percentDownloaded", percentDownloaded)
    }
}

extension DownloadDataSourceImpl: URLSessionTaskDelegate {

    func urlSession(_ session: URLSession, task: URLSessionTask, didFinishCollecting metrics: URLSessionTaskMetrics) {
        log("metrics:", metrics)
    }

    func urlSession(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: Error?) {
        if let error = error {
            log("didCompleteWithError: \(String(describing: error))")
            return
        }
        log("didComplete")
    }
}
