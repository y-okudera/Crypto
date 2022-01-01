//
//  PendingOperations.swift
//  DataSource
//
//  Created by Yuki Okudera on 2021/12/30.
//

import Foundation

public final class PendingOperations {
    lazy var downloaderInProgress: [String: Operation] = [:]
    lazy var downloaderQueue: OperationQueue = {
        var queue = OperationQueue()
        queue.name = "jp.yuoku.DataSource.DownloaderQueue"
        queue.maxConcurrentOperationCount = 1
        return queue
    }()

    lazy var encryptionInProgress: [String: Operation] = [:]
    lazy var encryptionQueue: OperationQueue = {
        var queue = OperationQueue()
        queue.name = "jp.yuoku.DataSource.EncryptionQueue"
        queue.maxConcurrentOperationCount = 1
        return queue
    }()

    lazy var registryInProgress: [String: Operation] = [:]
    lazy var registryQueue: OperationQueue = {
        var queue = OperationQueue()
        queue.name = "jp.yuoku.DataSource.RegistryQueue"
        queue.maxConcurrentOperationCount = 1
        return queue
    }()
}
