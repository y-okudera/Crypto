//
//  DownloadContextRepository.swift
//  DataSource
//
//  Created by Yuki Okudera on 2021/11/29.
//

import Foundation

public enum DownloadContextRepositoryProvider {
    public static func provide() -> DownloadContextRepository {
        return DownloadContextRepositoryImpl(realmDataStore: RealmDataStoreProvider.provide())
    }
}

public protocol DownloadContextRepository {
    func update(downloadContext: DownloadContext, updateBlock: @escaping(() -> Void))
}

final class DownloadContextRepositoryImpl: DownloadContextRepository {
    
    let realmDataStore: RealmDataStore
    
    init(realmDataStore: RealmDataStore) {
        self.realmDataStore = realmDataStore
    }
    
    func update(downloadContext: DownloadContext, updateBlock: @escaping(() -> Void)) {
        do {
            try realmDataStore.update(object: downloadContext, block: updateBlock)
        } catch {
            fatalError("Realm writing failed.")
        }
    }
}
