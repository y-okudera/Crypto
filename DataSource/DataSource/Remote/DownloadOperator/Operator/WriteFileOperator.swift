//
//  WriteFileOperator.swift
//  DataSource
//
//  Created by Yuki Okudera on 2021/12/31.
//

import Foundation

public protocol WriteFileOperatorProviding {
    func startWritingToFile(fileWriterMetadata: FileWriterMetadata, pendingOperations: PendingOperations)
    func fileWriterCompletion(fileWriter: FileWriter, pendingOperations: PendingOperations)
}

class WriteFileOperator: WriteFileOperatorProviding {
    func startWritingToFile(fileWriterMetadata: FileWriterMetadata, pendingOperations: PendingOperations) {
        let fileWriter = FileWriter(fileWriterMetadata: fileWriterMetadata)
        fileWriter.completionBlock = { [weak self] in
            self?.fileWriterCompletion(fileWriter: fileWriter, pendingOperations: pendingOperations)
        }
        pendingOperations.writingToFilesInProgress[fileWriter.fileWriterMetadata.contentId.description] = fileWriter
        pendingOperations.writingToFileQueue.addOperation(fileWriter)
    }

    func fileWriterCompletion(fileWriter: FileWriter, pendingOperations: PendingOperations) {
        if fileWriter.isCancelled {
            return
        }
        pendingOperations.writingToFilesInProgress[fileWriter.fileWriterMetadata.contentId.description] = nil
        log("Finish Writing File Operation", Thread.current, fileWriter.fileWriterMetadata.contentId)
    }
}
