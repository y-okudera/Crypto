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
        guard pendingOperations.encryptionInProgress[encryptorMetadata.contentId.description] == nil else {
            log("Already in progress. contentId: \(encryptorMetadata.contentId)")
            return
        }
        let encryptor = Encryptor(encryptorMetadata: encryptorMetadata)
        encryptor.completionBlock = { [weak self] in
            self?.encryptorCompletion(encryptor: encryptor, pendingOperations: pendingOperations)
        }
        pendingOperations.encryptionInProgress[encryptor.encryptorMetadata.contentId.description] = encryptor
        pendingOperations.encryptionQueue.addOperation(encryptor)
        log("encryptionInProgress", pendingOperations.encryptionInProgress.count)
    }

    func encryptorCompletion(encryptor: Encryptor, pendingOperations: PendingOperations) {
        if encryptor.isCancelled {
            return
        }
        pendingOperations.encryptionInProgress.removeValue(forKey: encryptor.encryptorMetadata.contentId.description)
        log("encryptionInProgress", pendingOperations.encryptionInProgress.count)
        log("Finish Encryption Operation", Thread.current, encryptor.encryptorMetadata.contentId)

        let registryMetadata = RegistryMetadata(encryptorMetadata: encryptor.encryptorMetadata)
        registryOperator.startRegistry(registryMetadata: registryMetadata, pendingOperations: pendingOperations)
    }
}
