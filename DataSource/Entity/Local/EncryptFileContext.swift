//
//  EncryptFileContext.swift
//  DataSource
//
//  Created by okudera on 2021/11/26.
//

import Foundation

public struct EncryptFileContext {
    public let filePath: String
    public let encryptContext: EncryptContext

    public init(filePath: String, encryptContext: EncryptContext) {
        self.filePath = filePath
        self.encryptContext = encryptContext
    }
}
