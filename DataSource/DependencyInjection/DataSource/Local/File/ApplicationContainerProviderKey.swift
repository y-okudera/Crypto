//
//  ApplicationContainerProviderKey.swift
//  DataSource
//
//  Created by Yuki Okudera on 2021/12/27.
//

import Foundation

private struct ApplicationContainerProviderKey: InjectionKey {
    static var currentValue: ApplicationContainerProviding = ApplicationContainer()
}

extension InjectedValues {
    public var applicationContainerProvider: ApplicationContainerProviding {
        get { Self[ApplicationContainerProviderKey.self] }
        set { Self[ApplicationContainerProviderKey.self] = newValue }
    }
}
