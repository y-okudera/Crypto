//
//  ViewController.swift
//  Crypto
//
//  Created by Yuki Okudera on 2021/11/13.
//

import UIKit
import DataSource

class ViewController: UIViewController {

    lazy var imageView: UIImageView? = {
        let w = UIScreen.main.bounds.width
        let imageView = UIImageView(frame: .init(x: 0, y: 0, width: w, height: w))
        imageView.contentMode = .scaleAspectFit
        self.view.addSubview(imageView)
        imageView.center = self.view.center
        return imageView
    }()

    let localFileDataStore = LocalFileDataStoreProvider.provide()

    override func viewDidLoad() {
        super.viewDidLoad()
        loadIfExists()
    }
}

// MARK: - demo
extension ViewController {

    private func loadIfExists() {
        // 保存済みなら読み込んで表示する
        // 未保存なら、一度保存してから読み込んで表示する
        if let data = self.loadSaltAndIv() {
            print("保存済みの情報で復号")
            if let decryptedData = localFileDataStore.readFile(
                cryptoFileContext: .init(fileName: "dog.png", salt: data.salt, iv: data.iv),
                password: "dd6yt-2aVstJ62absbPuHe4s8aFhdtSM"
            ) {
                imageView?.image = UIImage(data: decryptedData)
            } else {
                // FIXME: - Will be deleting files and database records.
                print("復号失敗")
            }

        } else {
            print("未保存")
            let dogImage = UIImage(named: "dog");
            let data = dogImage?.pngData() ?? Data()
            let salt = try! DataCipher.AES.generateRandomSalt()
            let iv = try! DataCipher.AES.generateRandomIv()

            saveSaltAndIv(salt: salt, iv: iv)
            localFileDataStore.writeFile(
                data: data,
                cryptoFileContext: .init(fileName: "dog.png", salt: salt, iv: iv),
                password: "dd6yt-2aVstJ62absbPuHe4s8aFhdtSM"
            )

            if let decryptedData = localFileDataStore.readFile(
                cryptoFileContext: .init(fileName: "dog.png", salt: salt, iv: iv),
                password: "dd6yt-2aVstJ62absbPuHe4s8aFhdtSM"
            ) {
                imageView?.image = UIImage(data: decryptedData)
            } else {
                // FIXME: - Will be deleting files and database records.
                print("復号失敗")
            }
        }
    }

    private func saveSaltAndIv(salt: Data, iv: Data) {
        UserDefaults.standard.set(salt, forKey: "demo_salt")
        UserDefaults.standard.set(iv, forKey: "demo_iv")
    }

    private func loadSaltAndIv() -> (salt: Data, iv: Data)? {
        guard let salt = UserDefaults.standard.data(forKey: "demo_salt"), let iv = UserDefaults.standard.data(forKey: "demo_iv") else {
            return nil
        }
        return (salt: salt, iv: iv)
    }
}
