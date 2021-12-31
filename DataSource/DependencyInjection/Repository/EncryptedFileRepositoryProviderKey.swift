//
//  EncryptedFileRepositoryProviderKey.swift
//  DataSource
//
//  Created by Yuki Okudera on 2021/12/27.
//

import Foundation

private struct EncryptedFileRepositoryProviderKey: InjectionKey {
    static var currentValue: EncryptedFileRepositoryProviding = EncryptedFileRepository()
}

extension InjectedValues {
    var encryptedFileRepositoryProvider: EncryptedFileRepositoryProviding {
        get { Self[EncryptedFileRepositoryProviderKey.self] }
        set { Self[EncryptedFileRepositoryProviderKey.self] = newValue }
    }
}
