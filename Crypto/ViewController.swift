//
//  ViewController.swift
//  Crypto
//
//  Created by Yuki Okudera on 2021/11/13.
//

import UIKit
import DataSource

class ViewController: UIViewController {

    let localFileDataStoreProvider = LocalFileDataStoreProvider.provide()
    override func viewDidLoad() {
        super.viewDidLoad()

        localFileDataStoreProvider.createDownloadDataDirectory()

        let dogImage = UIImage(named: "dog");
        let data = dogImage?.pngData() ?? Data()
        localFileDataStoreProvider.writeFile(
            fileName: "dog.png",
            data: data,
            commonKey: "dd6yt-2aVstJ62absbPuHe4s8aFhdtSM",
            iv: "5XUPCCw8gMbJtyd89-tmNHNMGZMCMHRE"
        )

        let w = UIScreen.main.bounds.width
        let imageView = UIImageView(frame: .init(x: 0, y: 0, width: w, height: w))
        imageView.contentMode = .scaleAspectFit
        self.view.addSubview(imageView)
        imageView.center = self.view.center

        if let decryptedData = localFileDataStoreProvider.readFile(
            fileName: "dog.png",
            commonKey: "dd6yt-2aVstJ62absbPuHe4s8aFhdtSM",
            iv: "5XUPCCw8gMbJtyd89-tmNHNMGZMCMHRE"
        ) {
            imageView.image = UIImage(data: decryptedData)

        } else {
            // FIXME: - Will be deleting files and database records.
        }
    }
}
