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

    let downloadDataSource = DownloadDataSourceProvider.provide()
    let localFileDataSource = LocalFileDataSourceProvider.provide()

    override func viewDidLoad() {
        super.viewDidLoad()

        loadIfExists()

        NotificationCenter.default.addObserver(
            self,
            selector: #selector(enterBackground),
            name: UIApplication.didEnterBackgroundNotification,
            object: nil
        )

        // foreground download
        let url = URL(string: "https://placehold.jp/24/cc9999/993333/150x100.png")!
        downloadDataSource.execute(url: url)
    }

    @objc
    private func enterBackground() {

        // background download
        let url = URL(string: "https://placehold.jp/24/cc9999/993333/150x100.png")!
        downloadDataSource.execute(url: url)
    }
}

// MARK: - demo
extension ViewController {

    private func loadIfExists() {
        // 保存済みなら読み込んで表示する
        // 未保存なら、一度保存してから読み込んで表示する
        if let data = self.loadSaltAndIv() {
            print("保存済みの情報で復号")

            let decryptFileContext = DecryptFileContext(
                filePath: localFileDataSource.downloadDataDirectory.appendingPathComponent("dog.png").path,
                salt: data.salt,
                iv: data.iv
            )
            if let decryptedData = localFileDataSource.readFile(
                decryptFileContext: decryptFileContext,
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
            let encryptContext = EncryptContext(plainData: data, salt: salt, iv: iv)
            let encryptFileContext = EncryptFileContext(
                filePath: localFileDataSource.downloadDataDirectory.appendingPathComponent("dog.png").path,
                encryptContext: encryptContext
            )
            localFileDataSource.writeFile(encryptFileContext: encryptFileContext, password: "dd6yt-2aVstJ62absbPuHe4s8aFhdtSM")

            imageView?.image = dogImage
        }
    }

    private func saveSaltAndIv(salt: Data, iv: Data) {
        UserDefaults.standard.set(salt, forKey: "dog_salt")
        UserDefaults.standard.set(iv, forKey: "dog_iv")
    }

    private func loadSaltAndIv() -> (salt: Data, iv: Data)? {
        guard let salt = UserDefaults.standard.data(forKey: "dog_salt"), let iv = UserDefaults.standard.data(forKey: "dog_iv") else {
            return nil
        }
        return (salt: salt, iv: iv)
    }
}
