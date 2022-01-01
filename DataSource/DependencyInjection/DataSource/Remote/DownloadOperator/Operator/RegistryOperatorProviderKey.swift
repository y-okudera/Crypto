//
//  RegistryOperatorProviderKey.swift
//  DataSource
//
//  Created by Yuki Okudera on 2021/12/31.
//

import Foundation

private struct RegistryOperatorProviderKey: InjectionKey {
    static var currentValue: RegistryOperatorProviding = RegistryOperator()
}

extension InjectedValues {
    public var registryOperatorProvider: RegistryOperatorProviding {
        get { Self[RegistryOperatorProviderKey.self] }
        set { Self[RegistryOperatorProviderKey.self] = newValue }
    }
}
