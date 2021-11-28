//
//  DownloadContext.swift
//  DataSource
//
//  Created by okudera on 2021/11/26.
//

import RealmSwift

public final class DownloadContext: RealmSwift.Object {
    @objc public dynamic var filePath: String = ""
    @objc public dynamic var taskId: Int = 0
    @objc public dynamic var index: Int = 0
    @objc public dynamic var isDownloaded: Bool = false

    public override class func primaryKey() -> String? {
        return "filePath"
    }

    public convenience init(filePath: String, taskId: Int, index: Int, isDownloaded: Bool) {
        self.init()
        self.filePath = filePath
        self.taskId = taskId
        self.index = index
        self.isDownloaded = isDownloaded
    }
}
