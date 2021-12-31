//
//  Encryptor.swift
//  DataSource
//
//  Created by Yuki Okudera on 2021/12/30.
//

import Foundation

public final class Encryptor: Operation {
    let encryptorMetadata: EncryptorMetadata

    init(encryptorMetadata: EncryptorMetadata) {
        self.encryptorMetadata = encryptorMetadata
    }

    public override func main() {
        if isCancelled {
            return
        }

        for (i, encryptorItem) in encryptorMetadata.encryptorItems.enumerated() {
            do {
                let salt = try AES.generateRandomSalt()
                let iv = try AES.generateRandomIv()
                let encryptedData = try AES.encrypt(
                    plainData: encryptorItem.plainData,
                    salt: salt,
                    iv: iv,
                    password: "Kx4gx-jr3AOCLLAhcmdjoDKSe_AB7GhAd7JSf9HmQDq0zTA0Ny-yXpn4_X9cRpDJ"
                )
                encryptorMetadata.encryptorItems[i].encryptedData = encryptedData
                encryptorMetadata.encryptorItems[i].salt = salt
                encryptorMetadata.encryptorItems[i].iv = iv
                encryptorMetadata.state = .dataEncrypted

            } catch {
                encryptorMetadata.state = .failed
                break
            }
        }
    }
}
