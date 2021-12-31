//
//  EncryptedFileRepository.swift
//  DataSource
//
//  Created by Yuki Okudera on 2021/11/29.
//

import Foundation

protocol EncryptedFileRepositoryProviding {
    func update(filePath: String, contentId: Int, index: Int, salt: Data, iv: Data)
}

final class EncryptedFileRepository: EncryptedFileRepositoryProviding {

    @Injected(\.realmDataStoreProvider)
    private var realmDataStore: RealmDataStoreProviding

    func update(filePath: String, contentId: Int, index: Int, salt: Data, iv: Data) {
        let encryptedFileEntity = EncryptedFileEntity(filePath: filePath, contentId: contentId, index: index, salt: salt, iv: iv)
        do {
            try realmDataStore.update(object: encryptedFileEntity, block: nil)
        } catch {
            fatalError("Realm writing failed.")
        }
    }
}
