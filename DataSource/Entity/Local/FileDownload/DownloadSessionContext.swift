//
//  DownloadSessionContext.swift
//  DataSource
//
//  Created by okudera on 2021/11/26.
//

import RealmSwift

final class DownloadSessionContext: RealmSwift.Object {
    @objc dynamic var sessionId: String = ""
    @objc dynamic var contentId: Int = 0
    let downloadContexts = List<DownloadContext>()

    override class func primaryKey() -> String? {
        return "sessionId"
    }

    convenience init(sessionId: String, contentId: Int, downloadContexts: [DownloadContext]) {
        self.init()
        self.sessionId = sessionId
        self.contentId = contentId
        self.downloadContexts.append(objectsIn: downloadContexts)
    }
}
