//
//  EncryptorMetadata.swift
//  DataSource
//
//  Created by Yuki Okudera on 2021/12/30.
//

import Foundation

public final class EncryptorMetadata {

    /// Used for directory names.
    let contentId: Int
    let encryptorItems: [EncryptorItem]
    var state: OperationState

    init(backgroundDownloaderMetadata: BackgroundDownloaderMetadata) {
        self.contentId = backgroundDownloaderMetadata.contentId
        self.encryptorItems = backgroundDownloaderMetadata.downloaderItems
            .filter { $0.isDownloaded }
            .map { .init(destinationPath: $0.destinationPath, plainData: $0.downloadedData!) }
        self.state = backgroundDownloaderMetadata.state
    }
}

final class EncryptorItem {
    let destinationPath: String
    let plainData: Data
    var encryptedData: Data?
    var salt: Data?
    var iv: Data?

    init(destinationPath: String, plainData: Data) {
        self.destinationPath = destinationPath
        self.plainData = plainData
    }
}
