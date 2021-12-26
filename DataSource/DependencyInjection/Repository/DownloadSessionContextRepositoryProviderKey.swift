//
//  DownloadSessionContextRepositoryProviderKey.swift
//  DataSource
//
//  Created by Yuki Okudera on 2021/12/27.
//

import Foundation

private struct DownloadSessionContextRepositoryProviderKey: InjectionKey {
    static var currentValue: DownloadSessionContextRepositoryProviding = DownloadSessionContextRepository()
}

extension InjectedValues {
    var downloadSessionContextRepositoryProvider: DownloadSessionContextRepositoryProviding {
        get { Self[DownloadSessionContextRepositoryProviderKey.self] }
        set { Self[DownloadSessionContextRepositoryProviderKey.self] = newValue }
    }
}
