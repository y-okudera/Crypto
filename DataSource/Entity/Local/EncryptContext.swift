//
//  EncryptContext.swift
//  DataSource
//
//  Created by okudera on 2021/11/26.
//

import Foundation

struct EncryptContext {
    let plainData: Data
    let salt: Data
    let iv: Data

    init(plainData: Data, salt: Data, iv: Data) {
        self.plainData = plainData
        self.salt = salt
        self.iv = iv
    }
}
