//
//  DownloadSessionContextRepositoryTests.swift
//  DataSourceTests
//
//  Created by Yuki Okudera on 2021/12/29.
//

import XCTest
@testable import DataSource

final class DownloadSessionContextRepositoryTests: XCTestCase {

    private let sut = DownloadSessionContextRepository()
    private var realmDataStoreProvidingMock = RealmDataStoreProvidingMock() {
        didSet {
            InjectedValues[\.realmDataStoreProvider] = realmDataStoreProvidingMock
        }
    }

    override func setUpWithError() throws {
        realmDataStoreProvidingMock = RealmDataStoreProvidingMock()
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testUpdate() {
        // setUp
        let sessionId = "sessionId"
        let contentId = 1
        let downloadContexts = [DownloadContext(filePath: "filePath", taskId: 2, index: 3, isDownloaded: true)]

        // Exercise
        sut.update(sessionId: sessionId, contentId: contentId, downloadContexts: downloadContexts)

        // Verify
        XCTAssertEqual(realmDataStoreProvidingMock.updateCallCount, 1)
        guard let updateArgValue = realmDataStoreProvidingMock.updateArgValues[0].0 as? DownloadSessionContext else {
            XCTFail("updateArgValues is empty")
            return
        }
        XCTAssertEqual(updateArgValue.sessionId, "sessionId")
        XCTAssertEqual(updateArgValue.contentId, 1)
        XCTAssertEqual(Array(updateArgValue.downloadContexts), [DownloadContext(filePath: "filePath", taskId: 2, index: 3, isDownloaded: true)])
    }

    func testRead() {
        // setUp
        let sessionId = "sessionId"
        realmDataStoreProvidingMock.findByIdHandler = { _, _ in
            return DownloadSessionContext(
                sessionId: "sessionId",
                contentId: 1,
                downloadContexts: [
                    DownloadContext(filePath: "filePath", taskId: 2, index: 3, isDownloaded: false),
                ]
            )
        }

        // Exercise
        let result = sut.read(sessionId: sessionId)

        // Verify
        XCTAssertEqual(realmDataStoreProvidingMock.findByIdCallCount, 1)
        XCTAssertEqual(realmDataStoreProvidingMock.findByIdArgValues[0].0 as? String, sessionId)
        XCTAssertEqual(realmDataStoreProvidingMock.findByIdArgValues[0].1.description(), DownloadSessionContext.self.description())
        do {
            let result = try XCTUnwrap(result)
            XCTAssertEqual(result.sessionId, "sessionId")
            XCTAssertEqual(result.contentId, 1)
            XCTAssertEqual(Array(result.downloadContexts), [DownloadContext(filePath: "filePath", taskId: 2, index: 3, isDownloaded: false)])
        } catch {
            XCTFail("Read data is nil.")
        }
    }

    func testDelete() {
        // setUp
        let sessionId = "sessionId"
        realmDataStoreProvidingMock.findByIdHandler = { _, _ in
            return DownloadSessionContext(
                sessionId: "sessionId",
                contentId: 1,
                downloadContexts: [
                    DownloadContext(filePath: "filePath", taskId: 2, index: 3, isDownloaded: false),
                ]
            )
        }

        // Exercise
        sut.delete(sessionId: sessionId)

        // Verify
        XCTAssertEqual(realmDataStoreProvidingMock.findByIdCallCount, 1)
        XCTAssertEqual(realmDataStoreProvidingMock.deleteObjectsCallCount, 1)
        XCTAssertEqual(realmDataStoreProvidingMock.deleteCallCount, 1)
    }
}
