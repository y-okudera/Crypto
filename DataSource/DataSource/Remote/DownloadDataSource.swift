//
//  DownloadDataSource.swift
//  DataSource
//
//  Created by Yuki Okudera on 2021/11/23.
//

import Foundation
import UIKit

public enum DownloadDataSourceProvider {
    public static func provide() -> DownloadDataSource {
        return DownloadDataSourceImpl()
    }
}

public protocol DownloadDataSource: AnyObject {
    func execute(url: URL)
}

final class DownloadDataSourceImpl: NSObject, DownloadDataSource {
    func execute(url: URL) {
        let configuration = BackgroundConfigurationGenerator.generate(identifier: UUID().uuidString)
        let session = URLSession(configuration: configuration, delegate: self, delegateQueue: .main)
        let backgroundTask = session.downloadTask(with: url)
        backgroundTask.earliestBeginDate = Date().addingTimeInterval(10)
        backgroundTask.countOfBytesClientExpectsToSend = 200
        backgroundTask.countOfBytesClientExpectsToReceive = 500 * 1024
        backgroundTask.resume()
    }
}

extension DownloadDataSourceImpl: URLSessionDelegate {

    func urlSession(_ session: URLSession, didBecomeInvalidWithError error: Error?) {
        log("didBecomeInvalidWithError: \(String(describing: error))")
    }

    func urlSessionDidFinishEvents(forBackgroundURLSession session: URLSession) {
        NotificationCenter.default.post(name: NotificationNames.downloadCompleted, object: nil)
    }
}

extension DownloadDataSourceImpl: URLSessionDownloadDelegate {

    func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didFinishDownloadingTo location: URL) {
        log("didFinishDownloadingTo", location)

#if DEBUG
        // write to files.
        do {
            let reader = try FileHandle(forReadingFrom: location)
            let data = reader.readDataToEndOfFile()

            let salt = try! DataCipher.AES.generateRandomSalt()
            let iv = try! DataCipher.AES.generateRandomIv()
            UserDefaults.standard.set(salt, forKey: "demo_salt")
            UserDefaults.standard.set(iv, forKey: "demo_iv")

            let localFileDataSource = LocalFileDataSourceProvider.provide()
            localFileDataSource.writeFile(
                data: data,
                cryptoFileContext: .init(fileName: "encrypted.png", salt: salt, iv: iv),
                password: "dd6yt-2aVstJ62absbPuHe4s8aFhdtSM"
            )
            localFileDataSource.writeFile(data: data, name: "plain.png")

        } catch {
            log(error)
        }
#endif
    }

    func urlSession(
        _ session: URLSession,
        downloadTask: URLSessionDownloadTask,
        didWriteData bytesWritten: Int64,
        totalBytesWritten: Int64,
        totalBytesExpectedToWrite: Int64
    ) {
        let percentDownloaded = totalBytesWritten / totalBytesExpectedToWrite
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
