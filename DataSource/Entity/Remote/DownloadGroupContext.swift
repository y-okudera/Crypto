//
//  DownloadGroupContext.swift
//  DataSource
//
//  Created by okudera on 2021/11/26.
//

import Foundation

public struct DownloadGroupContext {
    public let downloadContexts: [DownloadContext]

    public init(downloadContexts: [DownloadContext]) {
        self.downloadContexts = downloadContexts
    }
}
