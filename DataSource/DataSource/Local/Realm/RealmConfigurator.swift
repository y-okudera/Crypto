//
//  RealmConfigurator.swift
//  DataSource
//
//  Created by Yuki Okudera on 2021/11/28.
//

import RealmSwift

public enum RealmConfiguratorProvider {
    public static func provide(configuration: Realm.Configuration) -> RealmConfigurator {
        return RealmConfiguratorImpl(configuration: configuration)
    }
}

public protocol RealmConfigurator: AnyObject {
    var configuration: Realm.Configuration { get }
}

final class RealmConfiguratorImpl: RealmConfigurator {

    let configuration: Realm.Configuration

    init(configuration: Realm.Configuration) {
        self.configuration = configuration
    }
}
