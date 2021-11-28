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

    /// データを暗号化してファイルに書き込む
    func writeFile(filePath: String, salt: Data, iv: Data, password: String, from location: URL)

    /// ファイルを復号して読み込む
    func readFile(filePath: String, salt: Data, iv: Data, password: String) -> Data?
}

final class LocalFileDataSourceImpl: LocalFileDataSource {

    public var downloadDataDirectory: URL {
        let libraryDirectory = FileManager.default.urls(for: .libraryDirectory, in: .userDomainMask)[0]
        return libraryDirectory.appendingPathComponent("DownloadData", isDirectory: true)
    }

    /// ダウンロードファイルを保存するためのディレクトリを作成する
    func createDownloadDataDirectory() {
        let downloadDataDirectory = self.downloadDataDirectory
        log("downloadDataDirectory", downloadDataDirectory.absoluteString)
        createDirectory(path: downloadDataDirectory.path)
    }

    /// データを暗号化してファイルに書き込む
    func writeFile(filePath: String, salt: Data, iv: Data, password: String, from location: URL) {
        let directoryUrl = URL(fileURLWithPath: filePath).deletingLastPathComponent()
        createDirectory(path: directoryUrl.path)

        do {
            let reader = try FileHandle(forReadingFrom: location)
            let data = reader.readDataToEndOfFile()
            let encryptContext = EncryptContext(plainData: data, salt: salt, iv: iv)
            writeFile(filePath: filePath, encryptContext: encryptContext, password: password)
#if DEBUG
            let fileUrl = URL(fileURLWithPath: filePath)
            let fileName = fileUrl.lastPathComponent
            let plainDirectoryUrl = fileUrl.deletingLastPathComponent().appendingPathComponent("plain", isDirectory: true)
            createDirectory(path: plainDirectoryUrl.path)

            let plainFilePath = plainDirectoryUrl.appendingPathComponent(fileName, isDirectory: false).path
            writeFile(data: data, filePath: plainFilePath)
#endif
        } catch {
            log(error)
        }
    }

    /// ファイルを復号して読み込む
    func readFile(filePath: String, salt: Data, iv: Data, password: String) -> Data? {
        do {
            let encryptedData = try Data(contentsOf: URL(fileURLWithPath: filePath))
            let decryptContext = DecryptContext(encryptedData: encryptedData, salt: salt, iv: iv)
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

extension LocalFileDataSourceImpl {

    /// ディレクトリが存在しない場合、生成する
    private func createDirectory(path: String) {
        let url = URL(fileURLWithPath: path)
        // 既に存在する場合は作成しない
        if !FileManager.default.fileExists(atPath: path) {
            do {
                try FileManager.default.createDirectory(at: url, withIntermediateDirectories: true, attributes: nil)
            } catch {
                log("Create directory error", error)
            }
        }

        let nsUrl = url as NSURL
        do {
            // ストレージが少ない状態でもOSに削除させない
            // https://developer.apple.com/icloud/documentation/data-storage/index.html
            try nsUrl.setResourceValue(true, forKey: URLResourceKey.isExcludedFromBackupKey)
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
    private func writeFile(data: Data, filePath: String) -> Bool {
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
    private func writeFile(filePath: String, encryptContext: EncryptContext, password: String) -> Bool {
        do {
            let encryptedData = try DataCipher.AES.encrypt(encryptContext: encryptContext, password: password)
            let destination = URL(fileURLWithPath: filePath)
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
}
