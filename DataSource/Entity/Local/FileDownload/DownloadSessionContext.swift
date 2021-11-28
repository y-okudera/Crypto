//
//  DownloadSessionContext.swift
//  DataSource
//
//  Created by okudera on 2021/11/26.
//

import RealmSwift

public final class DownloadSessionContext: RealmSwift.Object {
    @objc public dynamic var sessionId: String = ""
    @objc public dynamic var contentId: Int = 0
    public let downloadContexts = List<DownloadContext>()

    public override class func primaryKey() -> String? {
        return "sessionId"
    }

    public convenience init(sessionId: String, contentId: Int, downloadContexts: [DownloadContext]) {
        self.init()
        self.sessionId = sessionId
        self.contentId = contentId
        self.downloadContexts.append(objectsIn: downloadContexts)
    }
}
