//
//  ApplicationContainer.swift
//  DataSource
//
//  Created by Yuki Okudera on 2021/11/14.
//

import Foundation

public protocol ApplicationContainerProviding {

    var downloadDataDirectory: URL { get }

    /// ダウンロードファイルを保存するためのディレクトリを作成する
    func createDownloadDataDirectory()

    /// ディレクトリが存在しない場合、生成する
    func createDirectory(path: String)

    /// データをファイルに書き込む
    /// - Parameters:
    ///   - data: 保存するデータ
    ///   - filePath: ファイルパス
    func writePlainData(_ data: Data, filePath: String) throws

    /// ファイルからデータを読み込む
    func readPlainData(filePath: String) throws -> Data

    /// データを暗号化してファイルに書き込む
    func writeEncryptedData(filePath: String, salt: Data, iv: Data, password: String, from location: URL)

    /// ファイルからデータを読み込んで復号する
    func readEncryptedData(filePath: String, salt: Data, iv: Data, password: String) -> Data?
}

final class ApplicationContainer: ApplicationContainerProviding {

    // MARK: - Handle directory

    public var downloadDataDirectory: URL {
        let libraryDirectory = FileManager.default.urls(for: .libraryDirectory, in: .userDomainMask)[0]
        return libraryDirectory.appendingPathComponent("DownloadData", isDirectory: true)
    }

    func createDownloadDataDirectory() {
        let downloadDataDirectory = self.downloadDataDirectory
        log("downloadDataDirectory", downloadDataDirectory.absoluteString)
        createDirectory(path: downloadDataDirectory.path)
    }

    func createDirectory(path: String) {
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

    // MARK: - Handle file with plain data

    func writePlainData(_ data: Data, filePath: String) throws {
        let destination = URL(fileURLWithPath: filePath)
        log("destination", filePath)

        do {
            try data.write(to: destination, options: .atomic)
        } catch {
            log("Write to file error: \(error)")
            throw error
        }
    }

    func readPlainData(filePath: String) throws -> Data {
        do {
            let data = try Data(contentsOf: URL(fileURLWithPath: filePath))
            return data
        } catch {
            log("URL cannot be read.", error)
            throw error
        }
    }

    // MARK: - Handle file with encrypted data

    func writeEncryptedData(filePath: String, salt: Data, iv: Data, password: String, from location: URL) {
        let directoryUrl = URL(fileURLWithPath: filePath).deletingLastPathComponent()
        createDirectory(path: directoryUrl.path)

        do {
            let reader = try FileHandle(forReadingFrom: location)
            let data = reader.readDataToEndOfFile()
            let encryptContext = EncryptContext(plainData: data, salt: salt, iv: iv)

            let encryptedData = try DataCipher.AES.encrypt(encryptContext: encryptContext, password: password)
            let destination = URL(fileURLWithPath: filePath)
            log("destination", destination.absoluteURL)
            try encryptedData.write(to: destination, options: .atomic)

#if DEBUG
            let fileUrl = URL(fileURLWithPath: filePath)
            let fileName = fileUrl.lastPathComponent
            let plainDirectoryUrl = fileUrl.deletingLastPathComponent().appendingPathComponent("plain", isDirectory: true)
            createDirectory(path: plainDirectoryUrl.path)

            let plainFilePath = plainDirectoryUrl.appendingPathComponent(fileName, isDirectory: false).path
            try writePlainData(data, filePath: plainFilePath)
#endif
        } catch let aesError as DataCipher.AES.Error {
            log("DataCipher.AES.encrypt AESError", aesError)
        } catch {
            log("Write to file error: \(error)")
        }
    }

    func readEncryptedData(filePath: String, salt: Data, iv: Data, password: String) -> Data? {
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
