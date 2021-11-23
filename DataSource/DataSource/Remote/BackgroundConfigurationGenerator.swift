//
//  BackgroundConfigurationGenerator.swift
//  DataSource
//
//  Created by Yuki Okudera on 2021/11/23.
//

import Foundation

enum BackgroundConfigurationGenerator {

    static func generate(
        identifier: String,
        allowsCellularAccess: Bool = true,
        isDiscretionary: Bool = true,
        sessionSendsLaunchEvents: Bool = true,
        timeoutIntervalForRequest: TimeInterval = 60,
        timeoutIntervalForResource: TimeInterval = 60 * 60 * 24
    ) -> URLSessionConfiguration {
        let configuration = URLSessionConfiguration.background(withIdentifier: identifier)
        configuration.allowsCellularAccess = allowsCellularAccess
        configuration.isDiscretionary = isDiscretionary
        configuration.sessionSendsLaunchEvents = sessionSendsLaunchEvents
        configuration.timeoutIntervalForRequest = timeoutIntervalForRequest
        configuration.timeoutIntervalForResource = timeoutIntervalForResource

        return configuration
    }
}
