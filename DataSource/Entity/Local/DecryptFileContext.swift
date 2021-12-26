//
//  DecryptFileContext.swift
//  DataSource
//
//  Created by okudera on 2021/11/26.
//

import Foundation

struct DecryptFileContext {
    let filePath: String
    let salt: Data
    let iv: Data

    init(filePath: String, salt: Data, iv: Data) {
        self.filePath = filePath
        self.salt = salt
        self.iv = iv
    }
}
