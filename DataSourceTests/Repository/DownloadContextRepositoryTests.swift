//
//  DownloadContextRepositoryTests.swift
//  DataSourceTests
//
//  Created by Yuki Okudera on 2021/12/28.
//

import XCTest
@testable import DataSource

final class DownloadContextRepositoryTests: XCTestCase {

    private let sut = DownloadContextRepository()
    private let realmDataStoreProvidingMock = RealmDataStoreProvidingMock()

    override func setUp() {
        InjectedValues[\.realmDataStoreProvider] = realmDataStoreProvidingMock
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testUpdate() {
        // setUp
        let expected = expectation(description: "Called Component Dependency")
        let downloadContext = DownloadContext(filePath: "filePath", taskId: 2, index: 3, isDownloaded: false)
        realmDataStoreProvidingMock.updateHandler = { object, updateBlock in
            // Verify
            XCTAssertEqual(object as? DownloadContext, downloadContext)
            updateBlock?()
        }

        // Exercise
        sut.update(downloadContext: downloadContext) {
            expected.fulfill()
        }

        wait(for: [expected], timeout: 0.3)
    }
}
