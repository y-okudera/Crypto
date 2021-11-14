//
//  LocalFileDataStore.swift
//  DataSource
//
//  Created by Yuki Okudera on 2021/11/14.
//

import Foundation

public enum LocalFileDataStoreProvider {
    public static func provide() -> LocalFileDataStore {
        return LocalFileDataStoreImpl()
    }
}

public protocol LocalFileDataStore {

    /// ダウンロードファイルを保存するためのディレクトリを作成する
    func createDownloadDataDirectory()

    /// DownloadDataディレクトリにファイルを保存する
    /// - Parameters:
    ///   - data: 保存するデータ
    ///   - cryptoFileContext: 暗号化するファイルの情報
    ///   - password: 共通パスワード
    /// - Returns: 保存 成功 or 失敗
    @discardableResult
    func writeFile(data: Data, cryptoFileContext: CryptoFileContext, password: String) -> Bool

    /// DownloadDataディレクトリのファイルを読み込む
    /// - Parameters:
    ///   - cryptoFileContext: 復号するファイルの情報
    ///   - password: 共通パスワード
    /// - Returns: 復号済みのデータ　復号失敗時はnil
    func readFile(cryptoFileContext: CryptoFileContext, password: String) -> Data?
}

final class LocalFileDataStoreImpl: LocalFileDataStore {

    init() {}

    private var downloadDataDirectory: URL {
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

    /// DownloadDataディレクトリにファイルを保存する
    /// - Parameters:
    ///   - data: 保存するデータ
    ///   - cryptoFileContext: 暗号化するファイルの情報
    ///   - password: 共通パスワード
    /// - Returns: 保存 成功 or 失敗
    @discardableResult
    func writeFile(data: Data, cryptoFileContext: CryptoFileContext, password: String) -> Bool {
        let downloadDataDirectory = self.downloadDataDirectory
        let destination = downloadDataDirectory.appendingPathComponent(cryptoFileContext.fileName, isDirectory: false)
        log("destination", destination.absoluteString)

        do {
            let encryptedData = try DataCipher.AES.encrypt(
                plainData: data,
                password: password,
                salt: cryptoFileContext.salt,
                iv: cryptoFileContext.iv
            )
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

    /// DownloadDataディレクトリのファイルを読み込む
    /// - Parameters:
    ///   - cryptoFileContext: 復号するファイルの情報
    ///   - password: 共通パスワード
    /// - Returns: 復号済みのデータ　復号失敗時はnil
    func readFile(cryptoFileContext: CryptoFileContext, password: String) -> Data? {
        let downloadDataDirectory = self.downloadDataDirectory
        let source = downloadDataDirectory.appendingPathComponent(cryptoFileContext.fileName, isDirectory: false)
        log("source", source.absoluteString)

        let fileUrl = URL(fileURLWithPath: source.path)

        do {
            let encryptedData = try Data(contentsOf: URL(fileURLWithPath: fileUrl.path))
            let data = try DataCipher.AES.decrypt(
                encryptedData: encryptedData,
                password: password,
                salt: cryptoFileContext.salt,
                iv: cryptoFileContext.iv
            )
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
