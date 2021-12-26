//
//  DownloadDataSourceProviderKey.swift
//  DataSource
//
//  Created by Yuki Okudera on 2021/12/27.
//

import Foundation

private struct DownloadDataSourceProviderKey: InjectionKey {
    static var currentValue: DownloadDataSourceProviding = DownloadDataSource(
        semaphore: DispatchSemaphore(value: 0),
        downloadQueue: DispatchQueue(label: "jp.yuoku.Crypto.Download", qos: .background)
    )
}

extension InjectedValues {
    public var downloadDataSourceProvider: DownloadDataSourceProviding {
        get { Self[DownloadDataSourceProviderKey.self] }
        set { Self[DownloadDataSourceProviderKey.self] = newValue }
    }
}
