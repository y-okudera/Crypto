//
//  DownloadManager.swift
//  DataSource
//
//  Created by Yuki Okudera on 2021/12/30.
//

import Foundation

public protocol DownloadManagerProviding {
    func startDownloads(backgroundDownloaderMetadata: BackgroundDownloaderMetadata)
}

class DownloadManager: DownloadManagerProviding {

    let pendingOperations = PendingOperations()

    @Injected(\.downloadOperatorProvider)
    private var downloadOperator: DownloadOperatorProviding

    func startDownloads(backgroundDownloaderMetadata: BackgroundDownloaderMetadata) {
        downloadOperator.startDownloads(backgroundDownloaderMetadata: backgroundDownloaderMetadata, pendingOperations: pendingOperations)
    }
}
