//
//  EncryptedFileContext.swift
//  DataSource
//
//  Created by Yuki Okudera on 2021/11/28.
//

import RealmSwift

public final class EncryptedFileContext: RealmSwift.Object {
    @objc public dynamic var filePath: String = ""
    @objc public dynamic var contentId: Int = 0
    @objc public dynamic var index: Int = 0
    @objc public dynamic var salt: Data = Data()
    @objc public dynamic var iv: Data = Data()

    public override class func primaryKey() -> String? {
        return "filePath"
    }

    public convenience init(filePath: String, contentId: Int, index: Int, salt: Data, iv: Data) {
        self.init()
        self.filePath = filePath
        self.contentId = contentId
        self.index = index
        self.salt = salt
        self.iv = iv
    }
}
