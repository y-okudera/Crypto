//
//  LocalFileDataSource.swift
//  DataSource
//
//  Created by Yuki Okudera on 2021/11/14.
//

import Foundation

public enum LocalFileDataSourceProvider {
    public static func provide() -> LocalFileDataSource {
        return LocalFileDataSourceImpl()
    }
}

public protocol LocalFileDataSource {

    var downloadDataDirectory: URL { get }

    /// ダウンロードファイルを保存するためのディレクトリを作成する
    func createDownloadDataDirectory()

    /// ファイルを保存する（暗号化なし）
    /// - Parameters:
    ///   - data: 保存するデータ
    ///   - filePath: ファイルパス
    /// - Returns: 保存 成功 or 失敗
    @discardableResult
    func writeFile(data: Data, filePath: String) -> Bool

    /// ファイルを保存する（暗号化あり）
    /// - Parameters:
    ///   - encryptFileContext: 暗号化するファイルの情報
    ///   - password: 共通パスワード
    /// - Returns: 保存 成功 or 失敗
    @discardableResult
    func writeFile(encryptFileContext: EncryptFileContext, password: String) -> Bool

    /// ファイルを読み込む（復号なし）
    /// - Returns: ファイルのデータ
    func readFile(filePath: String) -> Data?

    /// ファイルを読み込む（復号あり）
    /// - Parameters:
    ///   - decryptFileContext: 復号するファイルの情報
    ///   - password: 共通パスワード
    /// - Returns: 復号済みのデータ　復号失敗時はnil
    func readFile(decryptFileContext: DecryptFileContext, password: String) -> Data?
}

final class LocalFileDataSourceImpl: LocalFileDataSource {

    init() {}

    public var downloadDataDirectory: URL {
        let libraryDirectory = FileManager.default.urls(for: .libraryDirectory, in: .userDomainMask)[0]
        return libraryDirectory.appendingPathComponent("DownloadData", isDirectory: true)
    }

    /// ダウンロードファイルを保存するためのディレクトリを作成する
    func createDownloadDataDirectory() {
        let downloadDataDirectory = self.downloadDataDirectory
        log("downloadDataDirectory", downloadDataDirectory.absoluteString)

        // 既に存在する場合は作成しない
        if !FileManager.default.fileExists(atPath: downloadDataDirectory.path) {
            do {
                try FileManager.default.createDirectory(at: downloadDataDirectory, withIntermediateDirectories: true, attributes: nil)
            } catch {
                log("Create directory error", error)
            }
        }

        let url = URL(fileURLWithPath: downloadDataDirectory.path) as NSURL
        do {
            // ストレージが少ない状態でもOSに削除させない
            // https://developer.apple.com/icloud/documentation/data-storage/index.html
            try url.setResourceValue(true, forKey: URLResourceKey.isExcludedFromBackupKey)
        } catch {
            log("Sets the URL’s resource property error", error)
        }
    }

    /// ファイルを保存する（暗号化なし）
    /// - Parameters:
    ///   - data: 保存するデータ
    ///   - filePath: ファイルパス
    /// - Returns: 保存 成功 or 失敗
    @discardableResult
    func writeFile(data: Data, filePath: String) -> Bool {
        let destination = URL(fileURLWithPath: filePath)
        log("destination", filePath)

        do {
            try data.write(to: destination, options: .atomic)
            return true
        } catch {
            assertionFailure("Write to file error: \(error)")
            return false
        }
    }

    /// ファイルを保存する
    /// - Parameters:
    ///   - encryptFileContext: 暗号化するファイルの情報
    ///   - password: 共通パスワード
    /// - Returns: 保存 成功 or 失敗
    @discardableResult
    func writeFile(encryptFileContext: EncryptFileContext, password: String) -> Bool {
        do {
            let encryptedData = try DataCipher.AES.encrypt(
                encryptContext: encryptFileContext.encryptContext,
                password: password
            )
            let destination = URL(fileURLWithPath: encryptFileContext.filePath)
            log("destination", destination.absoluteURL)
            try encryptedData.write(to: destination, options: .atomic)
            return true
        } catch let aesError as DataCipher.AES.Error {
            log("DataCipher.AES.encrypt AESError", aesError)
            return false
        } catch {
            assertionFailure("Write to file error: \(error)")
            return false
        }
    }

    /// ファイルを読み込む（復号なし）
    /// - Returns: ファイルのデータ
    func readFile(filePath: String) -> Data? {
        do {
            let data = try Data(contentsOf: URL(fileURLWithPath: filePath))
            return data
        } catch {
            log("URL cannot be read.", error)
            return nil
        }
    }

    /// ファイルを読み込む
    /// - Parameters:
    ///   - decryptFileContext: 復号するファイルの情報
    ///   - password: 共通パスワード
    /// - Returns: 復号済みのデータ　復号失敗時はnil
    func readFile(decryptFileContext: DecryptFileContext, password: String) -> Data? {
        do {
            let encryptedData = try Data(contentsOf: URL(fileURLWithPath: decryptFileContext.filePath))
            let decryptContext = DecryptContext(encryptedData: encryptedData, salt: decryptFileContext.salt, iv: decryptFileContext.iv)
            let data = try DataCipher.AES.decrypt(decryptContext: decryptContext, password: password)
            return data
        } catch let aesError as DataCipher.AES.Error {
            log("DataCipher.AES.decrypt AESError", aesError)
            return nil
        } catch {
            log("URL cannot be read.", error)
            return nil
        }
    }
}
