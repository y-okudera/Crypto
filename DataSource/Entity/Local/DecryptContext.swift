//
//  DecryptContext.swift
//  DataSource
//
//  Created by okudera on 2021/11/26.
//

import Foundation

public struct DecryptContext {
    public let encryptedData: Data
    public let salt: Data
    public let iv: Data

    public init(encryptedData: Data, salt: Data, iv: Data) {
        self.encryptedData = encryptedData
        self.salt = salt
        self.iv = iv
    }
}
