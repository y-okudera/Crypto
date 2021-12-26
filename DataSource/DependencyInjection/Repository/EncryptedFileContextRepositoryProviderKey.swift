//
//  EncryptedFileContextRepositoryProviderKey.swift
//  DataSource
//
//  Created by Yuki Okudera on 2021/12/27.
//

import Foundation

private struct EncryptedFileContextRepositoryProviderKey: InjectionKey {
    static var currentValue: EncryptedFileContextRepositoryProviding = EncryptedFileContextRepository()
}

extension InjectedValues {
    public var encryptedFileContextRepositoryProvider: EncryptedFileContextRepositoryProviding {
        get { Self[EncryptedFileContextRepositoryProviderKey.self] }
        set { Self[EncryptedFileContextRepositoryProviderKey.self] = newValue }
    }
}
