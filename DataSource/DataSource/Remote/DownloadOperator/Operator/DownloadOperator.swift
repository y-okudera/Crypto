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
        guard pendingOperations.downloadsInProgress[backgroundDownloaderMetadata.contentId.description] == nil else {
            return
        }
        let downloader = BackgroundDownloader(backgroundDownloaderMetadata: backgroundDownloaderMetadata)
        downloader.completionBlock = { [weak self] in
            self?.downloadCompletion(downloader: downloader, pendingOperations: pendingOperations)
        }
        pendingOperations.downloadsInProgress[backgroundDownloaderMetadata.contentId.description] = downloader
        pendingOperations.downloadQueue.addOperation(downloader)
    }

    func downloadCompletion(downloader: BackgroundDownloader, pendingOperations: PendingOperations) {
        if downloader.isCancelled {
            return
        }
        let backgroundDownloaderMetadata = downloader.backgroundDownloaderMetadata
        pendingOperations.downloadsInProgress[backgroundDownloaderMetadata.contentId.description] = nil
        log("Finish Download Operation", Thread.current, backgroundDownloaderMetadata.contentId)

        let encryptorMetadata = EncryptorMetadata(backgroundDownloaderMetadata: backgroundDownloaderMetadata)
        encryptionOperator.startEncryption(encryptorMetadata: encryptorMetadata, pendingOperations: pendingOperations)
    }
}
