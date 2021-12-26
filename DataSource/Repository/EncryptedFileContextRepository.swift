//
//  EncryptedFileContextRepository.swift
//  DataSource
//
//  Created by Yuki Okudera on 2021/11/29.
//

import Foundation

public enum EncryptedFileContextRepositoryProvider {
    public static func provide() -> EncryptedFileContextRepository {
        return EncryptedFileContextRepositoryImpl()
    }
}

public protocol EncryptedFileContextRepository {
    func update(filePath: String, contentId: Int, index: Int, salt: Data, iv: Data)
}

final class EncryptedFileContextRepositoryImpl: EncryptedFileContextRepository {

    @Injected(\.realmDataStoreProvider)
    private var realmDataStore: RealmDataStoreProviding

    func update(filePath: String, contentId: Int, index: Int, salt: Data, iv: Data) {
        let encryptedFileContext = EncryptedFileContext(filePath: filePath, contentId: contentId, index: index, salt: salt, iv: iv)
        do {
            try realmDataStore.update(object: encryptedFileContext, block: nil)
        } catch {
            fatalError("Realm writing failed.")
        }
    }
}
