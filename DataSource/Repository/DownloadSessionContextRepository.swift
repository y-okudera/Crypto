//
//  DownloadSessionContextRepository.swift
//  DataSource
//
//  Created by Yuki Okudera on 2021/11/29.
//

import Foundation

public enum DownloadSessionContextRepositoryProvider {
    public static func provide() -> DownloadSessionContextRepository {
        return DownloadSessionContextRepositoryImpl(realmDataStore: RealmDataStoreProvider.provide())
    }
}

public protocol DownloadSessionContextRepository {
    func update(sessionId: String, contentId: Int, downloadContexts: [DownloadContext])

    func read(sessionId: String) -> DownloadSessionContext?
}

final class DownloadSessionContextRepositoryImpl: DownloadSessionContextRepository {

    let realmDataStore: RealmDataStore

    init(realmDataStore: RealmDataStore) {
        self.realmDataStore = realmDataStore
    }

    func update(sessionId: String, contentId: Int, downloadContexts: [DownloadContext]) {
        let downloadSessionContext = DownloadSessionContext(sessionId: sessionId, contentId: contentId, downloadContexts: downloadContexts)
        do {
            try realmDataStore.update(object: downloadSessionContext, block: nil)
        } catch {
            fatalError("Realm writing failed.")
        }
    }

    func read(sessionId: String) -> DownloadSessionContext? {
        return realmDataStore.findById(id: sessionId, for: DownloadSessionContext.self) as? DownloadSessionContext
    }
}
