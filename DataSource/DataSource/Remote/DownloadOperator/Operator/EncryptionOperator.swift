//
//  EncryptionOperator.swift
//  DataSource
//
//  Created by Yuki Okudera on 2021/12/31.
//

import Foundation

public protocol EncryptionOperatorProviding {
    func startEncryption(encryptorMetadata: EncryptorMetadata, pendingOperations: PendingOperations)
    func encryptorCompletion(encryptor: Encryptor, pendingOperations: PendingOperations)
}

class EncryptionOperator: EncryptionOperatorProviding {

    @Injected(\.registryOperatorProvider)
    private var registryOperator: RegistryOperatorProviding

    func startEncryption(encryptorMetadata: EncryptorMetadata, pendingOperations: PendingOperations) {
        let encryptor = Encryptor(encryptorMetadata: encryptorMetadata)
        encryptor.completionBlock = { [weak self] in
            self?.encryptorCompletion(encryptor: encryptor, pendingOperations: pendingOperations)
        }
        pendingOperations.encryptionsInProgress[encryptor.encryptorMetadata.contentId.description] = encryptor
        pendingOperations.encryptionQueue.addOperation(encryptor)
    }

    func encryptorCompletion(encryptor: Encryptor, pendingOperations: PendingOperations) {
        if encryptor.isCancelled {
            return
        }
        pendingOperations.encryptionsInProgress[encryptor.encryptorMetadata.contentId.description] = nil
        log("Finish Encryption Operation", Thread.current, encryptor.encryptorMetadata.contentId)

        let registryMetadata = RegistryMetadata(encryptorMetadata: encryptor.encryptorMetadata)
        registryOperator.startRegistry(registryMetadata: registryMetadata, pendingOperations: pendingOperations)
    }
}
