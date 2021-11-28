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

        NotificationCenter.default.addObserver(
            self,
            selector: #selector(enterBackground),
            name: UIApplication.didEnterBackgroundNotification,
            object: nil
        )

        // foreground download
        let urls = [
            URL(string: "https://placehold.jp/24/cc9999/993333/150x100.png")!,
            URL(string: "https://placehold.jp/24/cc9999/993333/150x110.png")!,
            URL(string: "https://placehold.jp/24/cc9999/993333/150x120.png")!,
            URL(string: "https://placehold.jp/24/cc9999/993333/150x130.png")!,
            URL(string: "https://placehold.jp/24/cc9999/993333/150x140.png")!,
            URL(string: "https://placehold.jp/24/cc9999/993333/150x150.png")!,
            URL(string: "https://placehold.jp/24/cc9999/993333/150x160.png")!,
            URL(string: "https://placehold.jp/24/cc9999/993333/150x170.png")!,
        ]
        downloadDataSource.execute(urls: urls)
    }

    @objc
    private func enterBackground() {

        // background download
        let urls = [
            URL(string: "https://placehold.jp/24/cc9999/993333/150x100.png")!,
            URL(string: "https://placehold.jp/24/cc9999/993333/150x110.png")!,
            URL(string: "https://placehold.jp/24/cc9999/993333/150x120.png")!,
            URL(string: "https://placehold.jp/24/cc9999/993333/150x130.png")!,
            URL(string: "https://placehold.jp/24/cc9999/993333/150x140.png")!,
            URL(string: "https://placehold.jp/24/cc9999/993333/150x150.png")!,
            URL(string: "https://placehold.jp/24/cc9999/993333/150x160.png")!,
            URL(string: "https://placehold.jp/24/cc9999/993333/150x170.png")!,
        ]
        downloadDataSource.execute(urls: urls)
    }
}
