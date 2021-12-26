//
//  RealmConfigurator.swift
//  DataSource
//
//  Created by Yuki Okudera on 2021/11/28.
//

import RealmSwift

public protocol RealmConfiguratorProviding {
    var configuration: Realm.Configuration { get }
}

final class RealmConfigurator: RealmConfiguratorProviding {

    let configuration: Realm.Configuration

    init(configuration: Realm.Configuration) {
        self.configuration = configuration
    }
}
