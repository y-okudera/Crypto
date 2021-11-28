//
//  DownloadContext.swift
//  DataSource
//
//  Created by okudera on 2021/11/26.
//

import Foundation

public struct DownloadContext: Equatable {
    public let sessionId: String
    public let taskId: Int
    public let filePath: String

    public init(sessionId: String, taskId: Int, filePath: String) {
        self.sessionId = sessionId
        self.taskId = taskId
        self.filePath = filePath
    }
}
