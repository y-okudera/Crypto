//
//  RealmDataStoreProviderKey.swift
//  DataSource
//
//  Created by Yuki Okudera on 2021/12/27.
//

import RealmSwift

private struct RealmDataStoreProviderKey: InjectionKey {
    static var currentValue: RealmDataStoreProviding = RealmDataStore()
}

extension InjectedValues {
    public var realmDataStoreProvider: RealmDataStoreProviding {
        get { Self[RealmDataStoreProviderKey.self] }
        set { Self[RealmDataStoreProviderKey.self] = newValue }
    }
}

