//
//  DownloadOperator.swift
//  DataSource
//
//  Created by Yuki Okudera on 2021/12/31.
//

import Foundation

public protocol DownloadOperatorProviding {
    func startDownloads(backgroundDownloaderMetadata: BackgroundDownloaderMetadata, pendingOperations: PendingOperations)
    func downloadCompletion(downloader: BackgroundDownloader, pendingOperations: PendingOperations)
}

class DownloadOperator: DownloadOperatorProviding {

    @Injected(\.encryptionOperatorProvider)
    private var encryptionOperator: EncryptionOperatorProviding

    func startDownloads(backgroundDownloaderMetadata: BackgroundDownloaderMetadata, pendingOperations: PendingOperations) {
        guard pendingOperations.downloaderInProgress[backgroundDownloaderMetadata.contentId.description] == nil else {
            log("Already in progress. contentId: \(backgroundDownloaderMetadata.contentId)")
            return
        }
        let downloader = BackgroundDownloader(backgroundDownloaderMetadata: backgroundDownloaderMetadata)
        downloader.completionBlock = { [weak self] in
            self?.downloadCompletion(downloader: downloader, pendingOperations: pendingOperations)
        }
        pendingOperations.downloaderInProgress[backgroundDownloaderMetadata.contentId.description] = downloader
        pendingOperations.downloaderQueue.addOperation(downloader)
        log("downloaderInProgress", pendingOperations.downloaderInProgress.count)
    }

    func downloadCompletion(downloader: BackgroundDownloader, pendingOperations: PendingOperations) {
        if downloader.isCancelled {
            return
        }
        let backgroundDownloaderMetadata = downloader.backgroundDownloaderMetadata
        pendingOperations.downloaderInProgress.removeValue(forKey: backgroundDownloaderMetadata.contentId.description)
        log("Finish Download Operation", Thread.current, backgroundDownloaderMetadata.contentId)
        log("downloaderInProgress", pendingOperations.downloaderInProgress.count)

        let encryptorMetadata = EncryptorMetadata(backgroundDownloaderMetadata: backgroundDownloaderMetadata)
        encryptionOperator.startEncryption(encryptorMetadata: encryptorMetadata, pendingOperations: pendingOperations)
    }
}
