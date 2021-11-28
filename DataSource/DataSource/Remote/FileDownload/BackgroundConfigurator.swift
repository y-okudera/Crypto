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
    func configuration(
        identifier: String,
        allowsCellularAccess: Bool,
        isDiscretionary: Bool,
        sessionSendsLaunchEvents: Bool,
        timeoutIntervalForRequest: TimeInterval,
        timeoutIntervalForResource: TimeInterval
    ) -> URLSessionConfiguration
}

extension BackgroundConfigurator {
    func configuration(
        identifier: String,
        allowsCellularAccess: Bool = true,
        isDiscretionary: Bool = true,
        sessionSendsLaunchEvents: Bool = true,
        timeoutIntervalForRequest: TimeInterval = 60,
        timeoutIntervalForResource: TimeInterval = 60 * 60 * 24
    ) -> URLSessionConfiguration {
        self.configuration(
            identifier: identifier,
            allowsCellularAccess: allowsCellularAccess,
            isDiscretionary: isDiscretionary,
            sessionSendsLaunchEvents: sessionSendsLaunchEvents,
            timeoutIntervalForRequest: timeoutIntervalForRequest,
            timeoutIntervalForResource: timeoutIntervalForResource
        )
    }
}

final class BackgroundConfiguratorImpl: BackgroundConfigurator {

    func configuration(
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
