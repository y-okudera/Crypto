//
//  CryptoFileContext.swift
//  DataSource
//
//  Created by Yuki Okudera on 2021/11/14.
//

import Foundation

public struct CryptoFileContext {
    public let fileName: String
    public let salt: Data
    public let iv: Data

    public init(fileName: String, salt: Data, iv: Data) {
        self.fileName = fileName
        self.salt = salt
        self.iv = iv
    }
}
