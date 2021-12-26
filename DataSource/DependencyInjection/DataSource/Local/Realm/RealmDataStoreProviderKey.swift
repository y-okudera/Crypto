//
//  RealmDataStoreProviderKey.swift
//  DataSource
//
//  Created by Yuki Okudera on 2021/12/27.
//

import Foundation
import RealmSwift

private struct RealmDataStoreProviderKey: InjectionKey {
    static var currentValue: RealmDataStoreProviding = {
        var configuration = Realm.Configuration()
        let keyString = "ssuMMd3a97IIGbGxF4kLP6y0Vf723qklg8IaIZHEQgUNnb9lE1W1wx4nlLCgQa0p"
        let keyData = keyString.data(using: .utf8)
        configuration.encryptionKey = keyData

        log("Realm encryptionKey -> " + keyData!.map { String(format: "%.2hhx", $0) }.joined())
        return RealmDataStore(realmConfigurator: RealmConfiguratorProvider.provide(configuration: configuration))
    }()
}

extension InjectedValues {
    public var realmDataStoreProvider: RealmDataStoreProviding {
        get { Self[RealmDataStoreProviderKey.self] }
        set { Self[RealmDataStoreProviderKey.self] = newValue }
    }
}

