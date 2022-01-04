//
//  DownloadManagerProviderKey.swift
//  DataSource
//
//  Created by Yuki Okudera on 2021/12/31.
//

import Foundation

private struct DownloadManagerProviderKey: InjectionKey {
    static var currentValue: DownloadManagerProviding = DownloadManager()
}

extension InjectedValues {
    public var downloadManagerProvider: DownloadManagerProviding {
        get { Self[DownloadManagerProviderKey.self] }
        set { Self[DownloadManagerProviderKey.self] = newValue }
    }
}
