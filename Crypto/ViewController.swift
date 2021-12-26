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

    override func viewDidLoad() {
        super.viewDidLoad()

        NotificationCenter.default.addObserver(
            self,
            selector: #selector(enterBackground),
            name: UIApplication.didEnterBackgroundNotification,
            object: nil
        )
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
        downloadDataSource.execute(contentId: 100, urls: urls)
    }

    @IBAction func tappedContent1Button(_ sender: UIButton) {
        print(#function)

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
        downloadDataSource.execute(contentId: 1, urls: urls)
    }

    @IBAction func tappedContent2Button(_ sender: UIButton) {
        print(#function)
        let urls = [
            URL(string: "https://placehold.jp/24/cc9999/993333/150x100.png")!,
            URL(string: "https://placehold.jp/24/cc9999/993333/150x110.png")!,
            URL(string: "https://placehold.jp/24/cc9999/993333/150x120.png")!,
            URL(string: "https://placehold.jp/24/cc9999/993333/150x130.png")!,
            URL(string: "https://placehold.jp/24/cc9999/993333/150x140.png")!,
            URL(string: "https://placehold.jp/24/cc9999/993333/150x150.png")!,
            URL(string: "https://placehold.jp/24/cc9999/993333/150x160.png")!,
            URL(string: "https://placehold.jp/24/cc9999/993333/150x170.png")!,
            URL(string: "https://placehold.jp/24/cc9999/993333/150x180.png")!,
            URL(string: "https://placehold.jp/24/cc9999/993333/150x190.png")!,
            URL(string: "https://placehold.jp/24/cc9999/993333/150x200.png")!,
        ]
        downloadDataSource.execute(contentId: 2, urls: urls)
    }

    @IBAction func tappedContent3Button(_ sender: UIButton) {
        print(#function)
        let urls = [
            URL(string: "https://placehold.jp/24/cc9999/993333/150x100.png")!,
            URL(string: "https://placehold.jp/24/cc9999/993333/150x110.png")!,
            URL(string: "https://placehold.jp/24/cc9999/993333/150x120.png")!,
            URL(string: "https://placehold.jp/24/cc9999/993333/150x130.png")!,
        ]
        downloadDataSource.execute(contentId: 3, urls: urls)
    }
}
