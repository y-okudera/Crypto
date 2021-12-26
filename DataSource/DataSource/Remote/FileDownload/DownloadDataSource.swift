//
//  DownloadDataSource.swift
//  DataSource
//
//  Created by Yuki Okudera on 2021/11/23.
//

import Foundation

public protocol DownloadDataSourceProviding {
    func execute(contentId: Int, urls: [URL])
}

final class DownloadDataSource: NSObject, DownloadDataSourceProviding {

    @Injected(\.backgroundConfiguratorProvider)
    private var backgroundConfigurator: BackgroundConfiguratorProviding

    @Injected(\.applicationContainerProvider)
    private var applicationContainer: ApplicationContainerProviding

    @Injected(\.downloadSessionContextRepositoryProvider)
    private var downloadSessionContextRepository: DownloadSessionContextRepositoryProviding

    @Injected(\.downloadContextRepositoryProvider)
    private var downloadContextRepository: DownloadContextRepositoryProviding

    @Injected(\.encryptedFileContextRepositoryProvider)
    private var encryptedFileContextRepository: EncryptedFileContextRepositoryProviding

    private let semaphore: DispatchSemaphore
    private let downloadQueue: DispatchQueue

    init(semaphore: DispatchSemaphore, downloadQueue: DispatchQueue) {
        self.semaphore = semaphore
        self.downloadQueue = downloadQueue
    }

    func execute(contentId: Int, urls: [URL]) {
        downloadQueue.async { [weak self] in
            guard let self = self else {
                return
            }

            let sessionIdentifier = UUID().uuidString
            log("START: \(sessionIdentifier)")

            let configuration = self.backgroundConfigurator.configuration(identifier: sessionIdentifier)
            let session = URLSession(configuration: configuration, delegate: self, delegateQueue: nil)

            var tuple = [(context: DownloadContext, downloadTask: URLSessionDownloadTask)]()
            for (index, url) in urls.enumerated() {
                let downloadTask = session.downloadTask(with: url)
                let destinationUrl = self.applicationContainer.downloadDataDirectory
                    .appendingPathComponent("\(contentId)", isDirectory: true)
                    .appendingPathComponent(url.lastPathComponent)
                let downloadContext = DownloadContext(
                    filePath: destinationUrl.path,
                    taskId: downloadTask.taskIdentifier,
                    index: index,
                    isDownloaded: false
                )
                tuple.append((context: downloadContext, downloadTask: downloadTask))
            }

            self.downloadSessionContextRepository.update(
                sessionId: sessionIdentifier,
                contentId: contentId,
                downloadContexts: tuple.map { $0.context }
            )

            tuple.forEach {
                $0.downloadTask.resume()
            }

            log("Will wait: \(sessionIdentifier)")
            self.semaphore.wait()
            log("End: \(sessionIdentifier)")
        }
    }
}

extension DownloadDataSource: URLSessionDelegate {

    func urlSession(_ session: URLSession, didBecomeInvalidWithError error: Error?) {
        log("didBecomeInvalidWithError: \(String(describing: error))")
    }

    func urlSessionDidFinishEvents(forBackgroundURLSession session: URLSession) {
        log("urlSessionDidFinishEvents")
        NotificationCenter.default.post(name: .downloadCompleted, object: nil)
    }
}

extension DownloadDataSource: URLSessionDownloadDelegate {

    func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didFinishDownloadingTo location: URL) {
        log("didFinishDownloadingTo", location)

        guard let sessionId = session.configuration.identifier,
              let downloadSessionContext = downloadSessionContextRepository.read(sessionId: sessionId),
              let downloadContext = downloadSessionContext.downloadContexts.filter({ $0.taskId == downloadTask.taskIdentifier }).first else {
                  return
              }

        do {
            let salt = try DataCipher.AES.generateRandomSalt()
            let iv = try DataCipher.AES.generateRandomIv()

            applicationContainer.writeEncryptedData(
                filePath: downloadContext.filePath,
                salt: salt,
                iv: iv,
                password: "Kx4gx-jr3AOCLLAhcmdjoDKSe_AB7GhAd7JSf9HmQDq0zTA0Ny-yXpn4_X9cRpDJ",
                from: location
            )

            downloadContextRepository.update(downloadContext: downloadContext) {
                downloadContext.isDownloaded = true
            }

            encryptedFileContextRepository.update(
                filePath: downloadContext.filePath,
                contentId: downloadSessionContext.contentId,
                index: downloadContext.index,
                salt: salt,
                iv: iv
            )

        } catch {
            fatalError("salt or iv generate failed.")
        }

        let allCount = Double(downloadSessionContext.downloadContexts.count)
        let downloadedCount = Double(downloadSessionContext.downloadContexts.filter { $0.isDownloaded == true }.count)
        log("PROGRESS:", Double(downloadedCount / allCount), "allCount:", allCount, "downloadedCount:", downloadedCount)
    }
}

extension DownloadDataSource: URLSessionTaskDelegate {

    func urlSession(_ session: URLSession, task: URLSessionTask, didFinishCollecting metrics: URLSessionTaskMetrics) {
        log("metrics:", metrics)
    }

    func urlSession(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: Error?) {
        if let error = error {
            log("didCompleteWithError: \(String(describing: error))")
            session.finishTasksAndInvalidate()
            semaphore.signal()
            return
        }

        guard let sessionId = session.configuration.identifier,
              let downloadSessionContext = downloadSessionContextRepository.read(sessionId: sessionId) else {
                  return
              }
        let allCount = Double(downloadSessionContext.downloadContexts.count)
        let downloadedCount = Double(downloadSessionContext.downloadContexts.filter { $0.isDownloaded == true }.count)

        if downloadedCount == allCount {
            log("didComplete \(sessionId)")
            session.finishTasksAndInvalidate()
            downloadSessionContextRepository.delete(sessionId: sessionId)
            semaphore.signal()
        }
    }
}
