//
//  DownloadContextRepository.swift
//  DataSource
//
//  Created by Yuki Okudera on 2021/11/29.
//

import Foundation

protocol DownloadContextRepositoryProviding {
    func update(downloadContext: DownloadContext, updateBlock: @escaping(() -> Void))
}

final class DownloadContextRepository: DownloadContextRepositoryProviding {

    @Injected(\.realmDataStoreProvider)
    private var realmDataStore: RealmDataStoreProviding

    func update(downloadContext: DownloadContext, updateBlock: @escaping(() -> Void)) {
        do {
            try realmDataStore.update(object: downloadContext, block: updateBlock)
        } catch {
            fatalError("Realm writing failed.")
        }
    }
}
