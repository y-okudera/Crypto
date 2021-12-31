//
//  BackgroundDownloaderMetadata.swift
//  DataSource
//
//  Created by Yuki Okudera on 2021/12/30.
//

import Foundation

public final class BackgroundDownloaderMetadata {

    /// Used for directory names.
    let contentId: Int
    let downloaderItems: [DownloaderItem]
    var sessionIdentifier: String?
    var state = OperationState.new

    public init(contentId: Int, downloaderItems: [DownloaderItem]) {
        self.contentId = contentId
        self.downloaderItems = downloaderItems
    }

    var isFinishedDownloading: Bool {
        return downloaderItems
            .filter { $0.downloadedData == nil }
            .isEmpty
    }
}

public final class DownloaderItem {
    let url: URL
    let destinationPath: String
    var downloadTaskIdentifier: Int?
    var downloadedData: Data?

    @Injected(\.applicationContainerProvider)
    private static var applicationContainer: ApplicationContainerProviding

    public init(url: URL, destinationPath: String) {
        self.url = url
        self.destinationPath = destinationPath
    }

    public convenience init(url: URL, contentId: Int) {
        let destinationPath = Self.applicationContainer.downloadDataDirectory
            .appendingPathComponent(contentId.description, isDirectory: true)
            .appendingPathComponent(url.lastPathComponent)
            .path
        self.init(url: url, destinationPath: destinationPath)
    }

    var isDownloaded: Bool {
        return downloadedData != nil
    }
}
