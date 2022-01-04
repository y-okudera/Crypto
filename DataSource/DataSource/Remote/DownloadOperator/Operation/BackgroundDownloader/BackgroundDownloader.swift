//
//  BackgroundDownloader.swift
//  DataSource
//
//  Created by Yuki Okudera on 2021/12/30.
//

import Foundation

public final class BackgroundDownloader: AsyncOperation {
    let backgroundDownloaderMetadata: BackgroundDownloaderMetadata
    var urlSessionDownloadTask: URLSessionDownloadTask?

    @Injected(\.backgroundConfiguratorProvider)
    private var backgroundConfigurator: BackgroundConfiguratorProviding

    private lazy var backgroundSession: URLSession = {
        let sessionIdentifier = UUID().uuidString
        backgroundDownloaderMetadata.sessionIdentifier = sessionIdentifier
        let configuration = backgroundConfigurator.configuration(identifier: sessionIdentifier)
        return URLSession(configuration: configuration, delegate: self, delegateQueue: nil)
    }()

    init(backgroundDownloaderMetadata: BackgroundDownloaderMetadata) {
        self.backgroundDownloaderMetadata = backgroundDownloaderMetadata
    }

    public override func main() {
        if isCancelled {
            return
        }

        let downloadTasks: [URLSessionDownloadTask] = backgroundDownloaderMetadata.downloaderItems.enumerated().map {
            let urlRequest = URLRequest(url: $0.element.url)
            let downloadTask = backgroundSession.downloadTask(with: urlRequest)
            backgroundDownloaderMetadata.downloaderItems[$0.offset].downloadTaskIdentifier = downloadTask.taskIdentifier
            return downloadTask
        }

        downloadTasks.forEach {
            $0.earliestBeginDate = Date().addingTimeInterval(10)
            $0.resume()
        }
    }
}

extension BackgroundDownloader: URLSessionDelegate {

    public func urlSession(_ session: URLSession, didBecomeInvalidWithError error: Error?) {
        log("didBecomeInvalidWithError: \(String(describing: error))")
    }

    public func urlSessionDidFinishEvents(forBackgroundURLSession session: URLSession) {
        log("urlSessionDidFinishEvents")
        NotificationCenter.default.post(name: .downloadCompleted, object: nil)
    }
}

extension BackgroundDownloader: URLSessionDownloadDelegate {

    public func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didFinishDownloadingTo location: URL) {
        log("didFinishDownloadingTo", location)

        guard
            let sessionIdentifier = session.configuration.identifier,
            backgroundDownloaderMetadata.sessionIdentifier == sessionIdentifier
        else {
            return
        }

        guard let downloadedData = (try? FileHandle(forReadingFrom: location))?.readDataToEndOfFile() else {
            backgroundDownloaderMetadata.state = .failed
            finish()
            return
        }

        if let index = backgroundDownloaderMetadata.downloaderItems.firstIndex(where: { $0.downloadTaskIdentifier == downloadTask.taskIdentifier }) {
            backgroundDownloaderMetadata.downloaderItems[index].downloadedData = downloadedData
        }

        if backgroundDownloaderMetadata.isFinishedDownloading {
            backgroundDownloaderMetadata.state = .dataDownloaded
            finish()
        }
    }
}

extension BackgroundDownloader: URLSessionTaskDelegate {

    public func urlSession(_ session: URLSession, task: URLSessionTask, didFinishCollecting metrics: URLSessionTaskMetrics) {
        log("metrics:", metrics)
    }

    public func urlSession(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: Error?) {
        if let error = error {
            log("didCompleteWithError: \(String(describing: error))")
            session.finishTasksAndInvalidate()
            backgroundDownloaderMetadata.state = .failed
            finish()
            return
        }
        log("didComplete")

        if backgroundDownloaderMetadata.isFinishedDownloading {
            session.finishTasksAndInvalidate()
        }
    }
}
