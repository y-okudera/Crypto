//
//  DownloadContextRepositoryProviderKey.swift
//  DataSource
//
//  Created by Yuki Okudera on 2021/12/27.
//

import Foundation

private struct DownloadContextRepositoryProviderKey: InjectionKey {
    static var currentValue: DownloadContextRepositoryProviding = DownloadContextRepository()
}

extension InjectedValues {
    public var downloadContextRepositoryProvider: DownloadContextRepositoryProviding {
        get { Self[DownloadContextRepositoryProviderKey.self] }
        set { Self[DownloadContextRepositoryProviderKey.self] = newValue }
    }
}

