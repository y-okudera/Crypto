//
//  Registry.swift
//  DataSource
//
//  Created by Yuki Okudera on 2021/12/31.
//

import Foundation

public final class Registry: Operation {

    @Injected(\.applicationContainerProvider)
    private var applicationContainer: ApplicationContainerProviding

    @Injected(\.encryptedFileRepositoryProvider)
    private var encryptedFileRepository: EncryptedFileRepositoryProviding

    let registryMetadata: RegistryMetadata

    public init(registryMetadata: RegistryMetadata) {
        self.registryMetadata = registryMetadata
    }

    public override func main() {
        if isCancelled {
            return
        }
        for (i, registryItem) in registryMetadata.registryItems.enumerated() {
            do {
                try applicationContainer.writeData(
                    registryItem.encryptedData,
                    filePath: registryItem.destinationPath
                )
                encryptedFileRepository.update(
                    filePath: registryItem.destinationPath,
                    contentId: registryMetadata.contentId,
                    index: i,
                    salt: registryItem.salt,
                    iv: registryItem.iv
                )
                if i == registryMetadata.registryItems.count - 1 {
                    registryMetadata.state = .writtenToFile
                }
            } catch {
                registryMetadata.state = .failed
                break
            }
        }
    }
}
