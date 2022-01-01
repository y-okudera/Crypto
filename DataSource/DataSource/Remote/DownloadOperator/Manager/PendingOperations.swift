//
//  PendingOperations.swift
//  DataSource
//
//  Created by Yuki Okudera on 2021/12/30.
//

import Foundation

public final class PendingOperations {
    lazy var downloadsInProgress: [String: Operation] = [:]
    lazy var downloadQueue: OperationQueue = {
        var queue = OperationQueue()
        queue.name = "Downloadueue"
        queue.maxConcurrentOperationCount = 1
        return queue
    }()

    lazy var encryptionsInProgress: [String: Operation] = [:]
    lazy var encryptionQueue: OperationQueue = {
        var queue = OperationQueue()
        queue.name = "EncryptionQueue"
        queue.maxConcurrentOperationCount = 1
        return queue
    }()

    lazy var registryInProgress: [String: Operation] = [:]
    lazy var registryQueue: OperationQueue = {
        var queue = OperationQueue()
        queue.name = "WritingToFileQueue"
        queue.maxConcurrentOperationCount = 1
        return queue
    }()
}
