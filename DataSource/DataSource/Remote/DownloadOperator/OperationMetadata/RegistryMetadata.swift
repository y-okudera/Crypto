//
//  RegistryMetadata.swift
//  DataSource
//
//  Created by Yuki Okudera on 2021/12/31.
//

import Foundation

public final class RegistryMetadata {

    /// Used for directory names.
    let contentId: Int
    let registryItems: [RegistryItem]
    var state: OperationState

    init(contentId: Int, registryItems: [RegistryItem], state: OperationState) {
        self.contentId = contentId
        self.registryItems = registryItems
        self.state = state
    }

    convenience init(encryptorMetadata: EncryptorMetadata) {
        self.init(
            contentId: encryptorMetadata.contentId,
            registryItems: encryptorMetadata.encryptorItems.compactMap { .init(encryptorItem: $0) },
            state: encryptorMetadata.state
        )
    }
}

final class RegistryItem {
    let destinationPath: String
    let plainData: Data
    let encryptedData: Data
    let salt: Data
    let iv: Data

    init(destinationPath: String, plainData: Data, encryptedData: Data, salt: Data, iv: Data) {
        self.destinationPath = destinationPath
        self.plainData = plainData
        self.encryptedData = encryptedData
        self.salt = salt
        self.iv = iv
    }

    convenience init?(encryptorItem: EncryptorItem) {
        guard
            let encryptedData = encryptorItem.encryptedData,
            let salt = encryptorItem.salt,
            let iv = encryptorItem.iv
        else {
            return nil
        }
        self.init(
            destinationPath: encryptorItem.destinationPath,
            plainData: encryptorItem.plainData,
            encryptedData: encryptedData,
            salt: salt,
            iv: iv
        )
    }
}
