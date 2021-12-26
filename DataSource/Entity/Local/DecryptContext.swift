//
//  DecryptContext.swift
//  DataSource
//
//  Created by okudera on 2021/11/26.
//

import Foundation

struct DecryptContext {
    let encryptedData: Data
    let salt: Data
    let iv: Data

    init(encryptedData: Data, salt: Data, iv: Data) {
        self.encryptedData = encryptedData
        self.salt = salt
        self.iv = iv
    }
}
