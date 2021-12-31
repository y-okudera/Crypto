//
//  EncryptedFileEntity.swift
//  DataSource
//
//  Created by Yuki Okudera on 2021/11/28.
//

import RealmSwift

final class EncryptedFileEntity: RealmSwift.Object {
    @objc dynamic var filePath: String = ""
    @objc dynamic var contentId: Int = 0
    @objc dynamic var index: Int = 0
    @objc dynamic var salt: Data = Data()
    @objc dynamic var iv: Data = Data()

    override class func primaryKey() -> String? {
        return "filePath"
    }

    convenience init(filePath: String, contentId: Int, index: Int, salt: Data, iv: Data) {
        self.init()
        self.filePath = filePath
        self.contentId = contentId
        self.index = index
        self.salt = salt
        self.iv = iv
    }
}
