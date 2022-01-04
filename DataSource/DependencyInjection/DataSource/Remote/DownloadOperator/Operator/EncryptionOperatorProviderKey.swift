//
//  EncryptionOperatorProviderKey.swift
//  DataSource
//
//  Created by Yuki Okudera on 2021/12/31.
//

import Foundation

private struct EncryptionOperatorProviderKey: InjectionKey {
    static var currentValue: EncryptionOperatorProviding = EncryptionOperator()
}

extension InjectedValues {
    public var encryptionOperatorProvider: EncryptionOperatorProviding {
        get { Self[EncryptionOperatorProviderKey.self] }
        set { Self[EncryptionOperatorProviderKey.self] = newValue }
    }
}
