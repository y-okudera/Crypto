//
//  DataCipher.swift
//  DataSource
//
//  Created by Yuki Okudera on 2021/11/14.
//

import CommonCrypto

public enum DataCipher {

    public enum CryptoOperationType: Equatable {
        case decrypt
        case encrypt
    }
}

extension DataCipher {

    public enum AESError: Error {
        case encodingFailed
        case invalidKeyLength
        case bufferIsEmpty
        case cryptoFailed(status: CCCryptorStatus)
    }

    public enum AES {

        // TODO: - Will be impl
//        public static func createRandomIv() throws -> Data {
//
//        }
//        public static func createRandomSalt() throws -> Data {
//
//        }
//        public static func createKey(commonKey: String, salt: String) throws -> Data {
//
//        }

        /// 暗号化
        /// - Parameters:
        ///   - plainData: 暗号化するデータ
        ///   - commonKey: 共通鍵
        ///   - iv: 初期化ベクトル
        /// - Returns: 暗号化されたデータ
        public static func encrypt(plainData: Data, commonKey: String, iv: String) throws -> Data {
            return try crypto(operation: .encrypt, sourceData: plainData, commonKey: commonKey, iv: iv)
        }

        /// 復号
        /// - Parameters:
        ///   - encryptedData: 復号するデータ
        ///   - commonKey: 共通鍵
        ///   - iv: 初期化ベクトル
        /// - Returns: 復号されたデータ
        public static func decrypt(encryptedData: Data, commonKey: String, iv: String) throws -> Data {
            return try crypto(operation: .decrypt, sourceData: encryptedData, commonKey: commonKey, iv: iv)
        }

        /// 暗号化 / 復号処理
        /// - Parameters:
        ///   - operation: 暗号化 or 復号
        ///   - sourceData: 捜査対象のデータ
        ///   - commonKey: 共通鍵
        ///   - iv: 初期化ベクトル
        /// - Returns: 処理結果のデータ
        private static func crypto(operation: CryptoOperationType, sourceData: Data, commonKey: String, iv: String) throws -> Data {
            log("start...", operation == .decrypt ? "復号処理" : "暗号化処理")
            log("commonKey", commonKey)
            log("iv", iv)
            log("sourceData size", sourceData.count)

            guard let initializationVector = iv.data(using: .utf8) else {
                assertionFailure("Encode iv failed")
                throw DataCipher.AESError.encodingFailed
            }

            guard let keyData = commonKey.data(using: .utf8) else {
                assertionFailure("Encode commonKey failed")
                throw DataCipher.AESError.encodingFailed
            }

            log("keyData.count", keyData.count, "kCCKeySizeAES256", kCCKeySizeAES256)
            guard keyData.count == kCCKeySizeAES256 else {
                assertionFailure("CommonKey invalid size")
                throw DataCipher.AESError.invalidKeyLength
            }

            let outputLength: size_t = {
                switch operation {
                case .decrypt:
                    // 復号後のデータのサイズを計算
                    return size_t(sourceData.count + kCCBlockSizeAES128)
                case .encrypt:
                    // 暗号化後のデータのサイズを計算
                    return size_t(Int(ceil(Double(sourceData.count / kCCBlockSizeAES128)) + 1.0) * kCCBlockSizeAES128)
                }
            }()

            var outputData = Data(count: outputLength)
            var numBytesEncrypted: size_t = 0

            let outputAddress = try outputData.withUnsafeMutableBytes { outputMutableRawBufferPointer -> UnsafeMutablePointer<UInt8> in
                log("outputMutableRawBufferPointer", outputMutableRawBufferPointer)
                let outputBufferPointer = outputMutableRawBufferPointer.bindMemory(to: UInt8.self)

                guard let outputAddress = outputBufferPointer.baseAddress else {
                    assertionFailure("outputBuffer is empty")
                    throw DataCipher.AESError.bufferIsEmpty
                }
                return outputAddress
            }

            let ivAddress = try initializationVector.withUnsafeBytes { ivMutableRawBufferPointer -> UnsafePointer<UInt8> in
                log("ivMutableRawBufferPointer", ivMutableRawBufferPointer)
                let ivBufferPointer = ivMutableRawBufferPointer.bindMemory(to: UInt8.self)

                guard let ivAddress = ivBufferPointer.baseAddress else {
                    assertionFailure("ivBuffer is empty")
                    throw DataCipher.AESError.bufferIsEmpty
                }
                return ivAddress
            }

            let sourceDataAddress = try sourceData.withUnsafeBytes { sourceDataMutableRawBufferPointer -> UnsafePointer<UInt8> in
                log("sourceDataMutableRawBufferPointer", sourceDataMutableRawBufferPointer)
                let sourceDataBufferPointer = sourceDataMutableRawBufferPointer.bindMemory(to: UInt8.self)
                guard let sourceDataAddress = sourceDataBufferPointer.baseAddress else {
                    assertionFailure("sourceDataBuffer is empty")
                    throw DataCipher.AESError.bufferIsEmpty
                }
                return sourceDataAddress
            }

            let keyAddress = try keyData.withUnsafeBytes { keyMutableRawBufferPointer -> UnsafePointer<UInt8> in
                log("keyMutableRawBufferPointer", keyMutableRawBufferPointer)
                let keyBufferPointer = keyMutableRawBufferPointer.bindMemory(to: UInt8.self)
                guard let keyAddress = keyBufferPointer.baseAddress else {
                    assertionFailure("keyBuffer is empty")
                    throw DataCipher.AESError.bufferIsEmpty
                }
                return keyAddress
            }

            // 暗号化 / 復号処理
            let cryptStatus = CCCrypt(
                CCOperation(operation == .decrypt ? kCCDecrypt : kCCEncrypt),
                CCAlgorithm(kCCAlgorithmAES),
                CCOptions(kCCOptionPKCS7Padding),
                keyAddress,
                keyData.count,
                ivAddress,
                sourceDataAddress,
                sourceData.count,
                outputAddress,
                outputLength,
                &numBytesEncrypted
            )

            guard cryptStatus == kCCSuccess else {
                throw DataCipher.AESError.cryptoFailed(status: cryptStatus)
            }

            log("outputData.count", outputData.count, "outputData.prefix(numBytesEncrypted)", outputData.prefix(numBytesEncrypted))
            switch operation {
            case .decrypt:
                // 追加されているPaddingの分は不要なため、必要なBuffer space分だけのデータを返却する
                return outputData.prefix(numBytesEncrypted)
            case .encrypt:
                return outputData
            }
        }
    }
}
