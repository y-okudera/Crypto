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

    public enum AES {

        public enum Error: Swift.Error {
            case secRandomCopyBytesFailed(status: Int)
            case keyGenerationFailed(status: Int)
            case encodingFailed
            case invalidKeyLength
            case bufferIsEmpty
            case cryptoFailed(status: CCCryptorStatus)
        }

        public static func generateRandomIv() throws -> Data {
            return try generateRandom(byteLength: kCCBlockSizeAES128)
        }

        public static func generateRandomSalt() throws -> Data {
            let saltSize = 20
            return try generateRandom(byteLength: saltSize)
        }

        /// 暗号化
        /// - Parameters:
        ///   - encryptContext: コンテキスト
        ///   - password: 共通パスワード
        /// - Returns: 暗号化されたデータ
        public static func encrypt(encryptContext: EncryptContext, password: String) throws -> Data {
            return try crypto(
                operation: .encrypt,
                sourceData: encryptContext.plainData,
                password: password,
                salt: encryptContext.salt,
                iv: encryptContext.iv
            )
        }

        /// 復号
        /// - Parameters:
        ///   - decryptContext: コンテキスト
        ///   - password: 共通パスワード
        /// - Returns: 復号されたデータ
        public static func decrypt(decryptContext: DecryptContext, password: String) throws -> Data {
            return try crypto(
                operation: .decrypt,
                sourceData: decryptContext.encryptedData,
                password: password,
                salt: decryptContext.salt,
                iv: decryptContext.iv
            )
        }

        /// キー生成
        /// - Parameters:
        ///   - password: 共通パスワード
        ///   - salt: ソルト
        /// - Returns: キーデータ
        private static func createKey(password: String, salt: Data) throws -> Data {
            let length = kCCKeySizeAES256
            var derivationStatus = Int32(0)
            var derivedBytes = [UInt8](repeating: 0, count: length)

            guard let passwordData = password.data(using: .utf8) else {
                assertionFailure("Encode passwordData failed")
                throw Self.Error.encodingFailed
            }

            let passwordBytes = try passwordData.withUnsafeBytes { rawBufferPointer -> UnsafePointer<Int8> in
                guard let passwordRawBytes = rawBufferPointer.baseAddress else {
                    assertionFailure("passwordBuffer is empty")
                    throw Self.Error.bufferIsEmpty
                }
                return passwordRawBytes.assumingMemoryBound(to: Int8.self)
            }
            let saltBytes = try salt.withUnsafeBytes { rawBufferPointer -> UnsafePointer<UInt8> in
                guard let saltRawBytes = rawBufferPointer.baseAddress else {
                    assertionFailure("saltBuffer is empty")
                    throw Self.Error.bufferIsEmpty
                }
                return saltRawBytes.assumingMemoryBound(to: UInt8.self)
            }

            derivationStatus = CCKeyDerivationPBKDF(
                CCPBKDFAlgorithm(kCCPBKDF2), // algorithm
                passwordBytes, // password
                passwordData.count, // passwordLen
                saltBytes, // salt
                salt.count, // saltLen
                CCPseudoRandomAlgorithm(kCCPRFHmacAlgSHA256), // prf
                10000, // rounds
                &derivedBytes, // derivedKey
                length // derivedKeyLen
            )

            guard derivationStatus == errSecSuccess else {
                assertionFailure("Key generation failed")
                throw Self.Error.keyGenerationFailed(status: Int(derivationStatus))
            }
            return Data(bytes: &derivedBytes, count: length)
        }

        /// ランダムデータ生成
        private static func generateRandom(byteLength: Int) throws -> Data {
            var outputData = Data(count: byteLength)
            let outputDataBytes = outputData.withUnsafeMutableBytes { mutableRawBufferPointer -> UnsafeMutablePointer<UInt8>? in
                let outputDataBufferPointer = mutableRawBufferPointer.bindMemory(to: UInt8.self)
                return outputDataBufferPointer.baseAddress
            }
            guard let outputDataBytes = outputDataBytes else {
                assertionFailure("outputDataBytes is empty")
                throw Self.Error.bufferIsEmpty
            }

            let status = SecRandomCopyBytes(
                kSecRandomDefault, // rnd
                byteLength, // count
                outputDataBytes // bytes
            )

            guard status == errSecSuccess else {
                assertionFailure("SecRandomCopyBytes failed byteLength: \(byteLength)")
                throw Self.Error.secRandomCopyBytesFailed(status: Int(status))
            }
            return outputData
        }

        /// 暗号化 / 復号処理
        /// - Parameters:
        ///   - operation: 暗号化 or 復号
        ///   - sourceData: 操作対象のデータ
        ///   - password: 共通パスワード
        ///   - salt: ソルト
        ///   - iv: 初期化ベクトル
        /// - Returns: 処理結果のデータ
        private static func crypto(operation: CryptoOperationType, sourceData: Data, password: String, salt: Data, iv: Data) throws -> Data {
            log("start...", operation == .decrypt ? "復号処理" : "暗号化処理")
            log("iv", iv)
            log("sourceData size", sourceData.count)

            let commonKeyData = try createKey(password: password, salt: salt)
            log("commonKeyData.count", commonKeyData.count, "kCCKeySizeAES256", kCCKeySizeAES256)
            guard commonKeyData.count == kCCKeySizeAES256 else {
                assertionFailure("CommonKey invalid size")
                throw Self.Error.invalidKeyLength
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

            let outputDataBytes = try outputData.withUnsafeMutableBytes { mutableRawBufferPointer -> UnsafeMutablePointer<UInt8> in
                log("outputMutableRawBufferPointer", mutableRawBufferPointer)
                let outputBufferPointer = mutableRawBufferPointer.bindMemory(to: UInt8.self)

                guard let outputDataBytes = outputBufferPointer.baseAddress else {
                    assertionFailure("outputBuffer is empty")
                    throw Self.Error.bufferIsEmpty
                }
                return outputDataBytes
            }

            let ivBytes = try iv.withUnsafeBytes { rawBufferPointer -> UnsafePointer<UInt8> in
                log("ivMutableRawBufferPointer", rawBufferPointer)
                let ivBufferPointer = rawBufferPointer.bindMemory(to: UInt8.self)

                guard let ivBytes = ivBufferPointer.baseAddress else {
                    assertionFailure("ivBuffer is empty")
                    throw Self.Error.bufferIsEmpty
                }
                return ivBytes
            }

            let sourceDataBytes = try sourceData.withUnsafeBytes { rawBufferPointer -> UnsafePointer<UInt8> in
                log("sourceDataMutableRawBufferPointer", rawBufferPointer)
                let sourceDataBufferPointer = rawBufferPointer.bindMemory(to: UInt8.self)
                guard let sourceDataBytes = sourceDataBufferPointer.baseAddress else {
                    assertionFailure("sourceDataBuffer is empty")
                    throw Self.Error.bufferIsEmpty
                }
                return sourceDataBytes
            }

            let commonKeyDataBytes = try commonKeyData.withUnsafeBytes { rawBufferPointer -> UnsafePointer<UInt8> in
                log("commonKeyMutableRawBufferPointer", rawBufferPointer)
                let commonKeyBufferPointer = rawBufferPointer.bindMemory(to: UInt8.self)
                guard let commonKeyDataBytes = commonKeyBufferPointer.baseAddress else {
                    assertionFailure("commonKeyBuffer is empty")
                    throw Self.Error.bufferIsEmpty
                }
                return commonKeyDataBytes
            }

            // 暗号化 / 復号処理
            let cryptStatus = CCCrypt(
                CCOperation(operation == .decrypt ? kCCDecrypt : kCCEncrypt), // op
                CCAlgorithm(kCCAlgorithmAES), // alg
                CCOptions(kCCOptionPKCS7Padding), // options
                commonKeyDataBytes, // key
                commonKeyData.count, // keyLength
                ivBytes, // iv
                sourceDataBytes, // dataIn
                sourceData.count, // dataInLength
                outputDataBytes, // dataOut
                outputLength, // dataOutAvailable
                &numBytesEncrypted // dataOutMoved
            )

            guard cryptStatus == kCCSuccess else {
                throw Self.Error.cryptoFailed(status: cryptStatus)
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
