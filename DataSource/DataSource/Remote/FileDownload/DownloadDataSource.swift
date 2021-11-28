//
//  DownloadDataSource.swift
//  DataSource
//
//  Created by Yuki Okudera on 2021/11/23.
//

import Foundation

public enum DownloadDataSourceProvider {
    public static func provide() -> DownloadDataSource {
        return DownloadDataSourceImpl(
            backgroundConfigurator: BackgroundConfiguratorProvider.provide(),
            localFileDataSource: LocalFileDataSourceProvider.provide(),
            realmDataStore: RealmDataStoreProvider.provide()
        )
    }
}

public protocol DownloadDataSource: AnyObject {
    func execute(contentId: Int, urls: [URL])
}

final class DownloadDataSourceImpl: NSObject, DownloadDataSource {

    let backgroundConfigurator: BackgroundConfigurator
    let localFileDataSource: LocalFileDataSource
    let realmDataStore: RealmDataStore

    init(backgroundConfigurator: BackgroundConfigurator, localFileDataSource: LocalFileDataSource, realmDataStore: RealmDataStore) {
        self.backgroundConfigurator = backgroundConfigurator
        self.localFileDataSource = localFileDataSource
        self.realmDataStore = realmDataStore
    }

    func execute(contentId: Int, urls: [URL]) {
        let sessionIdentifier = UUID().uuidString
        let configuration = backgroundConfigurator.configuration(identifier: sessionIdentifier)
        let session = URLSession(configuration: configuration, delegate: self, delegateQueue: .main)

        var tuple = [(context: DownloadContext, downloadTask: URLSessionDownloadTask)]()
        for (index, url) in urls.enumerated() {
            let downloadTask = session.downloadTask(with: url)
            downloadTask.earliestBeginDate = Date().addingTimeInterval(5)
            downloadTask.countOfBytesClientExpectsToSend = 250
            downloadTask.countOfBytesClientExpectsToReceive = 10 * 1024

            let destinationUrl = localFileDataSource.downloadDataDirectory
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

        updateDownloadSessionContext(sessionId: sessionIdentifier, contentId: contentId, downloadContexts: tuple.map { $0.context })

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

        guard
            let sessionId = session.configuration.identifier,
            let downloadSessionContext = readDownloadSessionContext(sessionId: sessionId),
            let downloadContext = downloadSessionContext.downloadContexts.filter({ $0.taskId == downloadTask.taskIdentifier }).first else {
                return
            }

        do {
            let salt = try DataCipher.AES.generateRandomSalt()
            let iv = try DataCipher.AES.generateRandomIv()

            localFileDataSource.writeFile(
                filePath: downloadContext.filePath,
                salt: salt,
                iv: iv,
                password: "Kx4gx-jr3AOCLLAhcmdjoDKSe_AB7GhAd7JSf9HmQDq0zTA0Ny-yXpn4_X9cRpDJ",
                from: location
            )

            updateDownloadContext(downloadContext: downloadContext)
            addEncryptedFileContext(
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

extension DownloadDataSourceImpl {

    /// Write to database
    private func updateDownloadSessionContext(sessionId: String, contentId: Int, downloadContexts: [DownloadContext]) {
        let downloadSessionContext = DownloadSessionContext(sessionId: sessionId, contentId: contentId, downloadContexts: downloadContexts)
        do {
            try realmDataStore.update(object: downloadSessionContext, block: nil)
        } catch {
            fatalError("Realm writing failed.")
        }
    }

    /// Read from database
    private func readDownloadSessionContext(sessionId: String) -> DownloadSessionContext? {
        return realmDataStore.findById(id: sessionId, for: DownloadSessionContext.self) as? DownloadSessionContext
    }

    /// Write to database
    private func updateDownloadContext(downloadContext: DownloadContext) {
        do {
            try realmDataStore.update(object: downloadContext, block: {
                downloadContext.isDownloaded = true
            })
        } catch {
            fatalError("Realm writing failed.")
        }
    }

    /// Write to database
    private func addEncryptedFileContext(filePath: String, contentId: Int, index: Int, salt: Data, iv: Data) {
        let encryptedFileContext = EncryptedFileContext(filePath: filePath, contentId: contentId, index: index, salt: salt, iv: iv)
        do {
            try realmDataStore.update(object: encryptedFileContext, block: nil)
        } catch {
            fatalError("Realm writing failed.")
        }
    }
}
