//
//  EncryptContext.swift
//  DataSource
//
//  Created by okudera on 2021/11/26.
//

import Foundation

public struct EncryptContext {
    public let plainData: Data
    public let salt: Data
    public let iv: Data

    public init(plainData: Data, salt: Data, iv: Data) {
        self.plainData = plainData
        self.salt = salt
        self.iv = iv
    }
}
