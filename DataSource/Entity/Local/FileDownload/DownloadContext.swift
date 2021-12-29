//
//  DownloadContext.swift
//  DataSource
//
//  Created by okudera on 2021/11/26.
//

import RealmSwift

final class DownloadContext: RealmSwift.Object {
    @objc dynamic var filePath: String = ""
    @objc dynamic var taskId: Int = 0
    @objc dynamic var index: Int = 0
    @objc dynamic var isDownloaded: Bool = false

    override class func primaryKey() -> String? {
        return "filePath"
    }

    override func isEqual(_ object: Any?) -> Bool {
        guard let object = object as? Self else {
            return false
        }
        return filePath == object.filePath
        && taskId == object.taskId
        && index == object.index
        && isDownloaded == object.isDownloaded
    }

    convenience init(filePath: String, taskId: Int, index: Int, isDownloaded: Bool) {
        self.init()
        self.filePath = filePath
        self.taskId = taskId
        self.index = index
        self.isDownloaded = isDownloaded
    }
}
