//
//  BackgroundConfigurator.swift
//  DataSource
//
//  Created by Yuki Okudera on 2021/11/23.
//

import Foundation

enum BackgroundConfiguratorProvider {
    static func provide() -> BackgroundConfigurator {
        return BackgroundConfiguratorImpl()
    }
}

protocol BackgroundConfigurator {
    func configuration(identifier: String) -> URLSessionConfiguration
}

final class BackgroundConfiguratorImpl: BackgroundConfigurator {

    func configuration(identifier: String) -> URLSessionConfiguration {
        let configuration = URLSessionConfiguration.background(withIdentifier: identifier)
        configuration.isDiscretionary = true
        configuration.timeoutIntervalForResource = 60 * 60 * 24

        return configuration
    }
}
