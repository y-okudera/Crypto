//
//  FileWriter.swift
//  DataSource
//
//  Created by Yuki Okudera on 2021/12/31.
//

import Foundation

public final class FileWriter: Operation {

    @Injected(\.applicationContainerProvider)
    private var applicationContainer: ApplicationContainerProviding

    @Injected(\.encryptedFileRepositoryProvider)
    private var encryptedFileRepository: EncryptedFileRepositoryProviding

    let fileWriterMetadata: FileWriterMetadata

    public init(fileWriterMetadata: FileWriterMetadata) {
        self.fileWriterMetadata = fileWriterMetadata
    }

    public override func main() {
        if isCancelled {
            return
        }
        for (i, fileWriterItem) in fileWriterMetadata.fileWriterItems.enumerated() {
            do {
                try applicationContainer.writeData(
                    fileWriterItem.encryptedData,
                    filePath: fileWriterItem.destinationPath
                )
                encryptedFileRepository.update(
                    filePath: fileWriterItem.destinationPath,
                    contentId: fileWriterMetadata.contentId,
                    index: i,
                    salt: fileWriterItem.salt,
                    iv: fileWriterItem.iv
                )
                if i == fileWriterMetadata.fileWriterItems.count - 1 {
                    fileWriterMetadata.state = .writtenToFile
                }
            } catch {
                fileWriterMetadata.state = .failed
                break
            }
        }
    }
}
