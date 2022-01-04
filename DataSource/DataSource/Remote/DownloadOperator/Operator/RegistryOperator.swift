//
//  RegistryOperator.swift
//  DataSource
//
//  Created by Yuki Okudera on 2021/12/31.
//

import Foundation

public protocol RegistryOperatorProviding {
    func startRegistry(registryMetadata: RegistryMetadata, pendingOperations: PendingOperations)
    func registryCompletion(registry: Registry, pendingOperations: PendingOperations)
}

class RegistryOperator: RegistryOperatorProviding {
    func startRegistry(registryMetadata: RegistryMetadata, pendingOperations: PendingOperations) {
        guard pendingOperations.registryInProgress[registryMetadata.contentId.description] == nil else {
            log("Already in progress. contentId: \(registryMetadata.contentId)")
            return
        }
        let registry = Registry(registryMetadata: registryMetadata)
        registry.completionBlock = { [weak self] in
            self?.registryCompletion(registry: registry, pendingOperations: pendingOperations)
        }
        pendingOperations.registryInProgress[registry.registryMetadata.contentId.description] = registry
        pendingOperations.registryQueue.addOperation(registry)
        log("registryInProgress", pendingOperations.registryInProgress.count)
    }

    func registryCompletion(registry: Registry, pendingOperations: PendingOperations) {
        if registry.isCancelled {
            return
        }
        pendingOperations.registryInProgress.removeValue(forKey: registry.registryMetadata.contentId.description)
        log("Finish Registry Operation", Thread.current, registry.registryMetadata.contentId)
        log("registryInProgress", pendingOperations.registryInProgress.count)
    }
}
