//
//  DownloadGroupStore.swift
//  DataSource
//
//  Created by okudera on 2021/11/26.
//

import Foundation

// TODO: - Save to database instead of singleton.
struct DownloadGroupStore {
    static var shared = DownloadGroupStore()

    private(set) var targetGroup: DownloadGroupContext = .init(downloadContexts: [])
    private(set) var finishedGroup: DownloadGroupContext = .init(downloadContexts: [])

    private init() {}

    mutating func clear() {
        targetGroup = .init(downloadContexts: [])
        finishedGroup = .init(downloadContexts: [])
    }

    mutating func addTargetContexts(downloadContexts: [DownloadContext]) {
        targetGroup = .init(downloadContexts: downloadContexts)
    }

    mutating func addFinishedContext(downloadContext: DownloadContext) {
        let newDownloadContexts = finishedGroup.downloadContexts + [downloadContext]
        finishedGroup = .init(downloadContexts: newDownloadContexts)
    }

    func specificDownloadContext(sessionId: String?, taskId: Int) -> DownloadContext? {
        guard let sessionId = sessionId else {
            return nil
        }
        let specificDownloadContext = targetGroup.downloadContexts
            .filter { $0.sessionId == sessionId && $0.taskId == taskId }
            .first
        guard let specificDownloadContext = specificDownloadContext else {
            return nil
        }
        return specificDownloadContext
    }

    var progress: Double {
        if targetGroup.downloadContexts.isEmpty {
            return 0
        }
        return Double(finishedGroup.downloadContexts.count) / Double(targetGroup.downloadContexts.count)
    }
}
