//
//  DownloadOperatorProviderKey.swift
//  DataSource
//
//  Created by Yuki Okudera on 2021/12/31.
//

import Foundation

private struct DownloadOperatorProviderKey: InjectionKey {
    static var currentValue: DownloadOperatorProviding = DownloadOperator()
}

extension InjectedValues {
    public var downloadOperatorProvider: DownloadOperatorProviding {
        get { Self[DownloadOperatorProviderKey.self] }
        set { Self[DownloadOperatorProviderKey.self] = newValue }
    }
}
