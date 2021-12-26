//
//  BackgroundConfigurator.swift
//  DataSource
//
//  Created by Yuki Okudera on 2021/11/23.
//

import Foundation

protocol BackgroundConfiguratorProviding {
    func configuration(identifier: String) -> URLSessionConfiguration
}

final class BackgroundConfigurator: BackgroundConfiguratorProviding {

    func configuration(identifier: String) -> URLSessionConfiguration {
        let configuration = URLSessionConfiguration.background(withIdentifier: identifier)
        configuration.isDiscretionary = true
        configuration.timeoutIntervalForResource = 60 * 60 * 24

        return configuration
    }
}
