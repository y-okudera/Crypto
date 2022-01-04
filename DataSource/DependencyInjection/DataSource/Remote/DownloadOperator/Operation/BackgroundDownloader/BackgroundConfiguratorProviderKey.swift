//
//  BackgroundConfiguratorProviderKey.swift
//  DataSource
//
//  Created by Yuki Okudera on 2021/12/27.
//

import Foundation

private struct BackgroundConfiguratorProviderKey: InjectionKey {
    static var currentValue: BackgroundConfiguratorProviding = BackgroundConfigurator()
}

extension InjectedValues {
    var backgroundConfiguratorProvider: BackgroundConfiguratorProviding {
        get { Self[BackgroundConfiguratorProviderKey.self] }
        set { Self[BackgroundConfiguratorProviderKey.self] = newValue }
    }
}
