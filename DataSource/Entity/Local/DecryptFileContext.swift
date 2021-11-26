//
//  DecryptFileContext.swift
//  DataSource
//
//  Created by okudera on 2021/11/26.
//

import Foundation

public struct DecryptFileContext {
    public let filePath: String
    public let salt: Data
    public let iv: Data

    public init(filePath: String, salt: Data, iv: Data) {
        self.filePath = filePath
        self.salt = salt
        self.iv = iv
    }
}
