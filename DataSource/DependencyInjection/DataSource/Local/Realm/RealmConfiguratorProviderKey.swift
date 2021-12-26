//
//  RealmConfiguratorProviderKey.swift
//  DataSource
//
//  Created by Yuki Okudera on 2021/12/27.
//

import RealmSwift

private struct RealmConfiguratorProviderKey: InjectionKey {
    static var currentValue: RealmConfiguratorProviding = {
        var configuration = Realm.Configuration()
        let keyString = "ssuMMd3a97IIGbGxF4kLP6y0Vf723qklg8IaIZHEQgUNnb9lE1W1wx4nlLCgQa0p"
        let keyData = keyString.data(using: .utf8)
        configuration.encryptionKey = keyData
        log("Realm encryptionKey -> " + keyData!.map { String(format: "%.2hhx", $0) }.joined())
        return RealmConfigurator(configuration: configuration)
    }()
}

extension InjectedValues {
    var realmConfiguratorProvider: RealmConfiguratorProviding {
        get { Self[RealmConfiguratorProviderKey.self] }
        set { Self[RealmConfiguratorProviderKey.self] = newValue }
    }
}
