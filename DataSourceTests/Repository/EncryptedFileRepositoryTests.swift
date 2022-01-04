//
//  EncryptedFileRepositoryTests.swift
//  DataSourceTests
//
//  Created by Yuki Okudera on 2021/12/29.
//

import XCTest
@testable import DataSource

final class EncryptedFileContextRepositoryTests: XCTestCase {

    private let sut = EncryptedFileRepository()
    private let realmDataStoreProvidingMock = RealmDataStoreProvidingMock()

    override func setUp() {
        InjectedValues[\.realmDataStoreProvider] = realmDataStoreProvidingMock
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testUpdate() {
        // setUp
        let salt = "salt".data(using: .utf8)!
        let iv = "iv".data(using: .utf8)!

        // Exercise
        sut.update(filePath: "filePath", contentId: 1, index: 2, salt: salt, iv: iv)

        // Verify
        XCTAssertEqual(realmDataStoreProvidingMock.updateCallCount, 1)
        guard let updateArgValue = realmDataStoreProvidingMock.updateArgValues[0].0 as? EncryptedFileEntity else {
            XCTFail("updateArgValues is empty")
            return
        }
        XCTAssertEqual(updateArgValue.filePath, "filePath")
        XCTAssertEqual(updateArgValue.contentId, 1)
        XCTAssertEqual(updateArgValue.index, 2)
        XCTAssertEqual(updateArgValue.salt, "salt".data(using: .utf8))
        XCTAssertEqual(updateArgValue.iv, "iv".data(using: .utf8))
    }
}
