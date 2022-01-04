//
//  DownloadManagerWrapper.swift
//  Crypto
//
//  Created by Yuki Okudera on 2021/12/31.
//

import DataSource
import Foundation

final class DownloadManagerWrapper {

    @Injected(\.downloadManagerProvider)
    private var downloadManager: DownloadManagerProviding

    init() {
        // Injection when replacing the operator implementation.
    }

    func startDownloads(backgroundDownloaderMetadata: BackgroundDownloaderMetadata) {
        downloadManager.startDownloads(backgroundDownloaderMetadata: backgroundDownloaderMetadata)
    }
}
