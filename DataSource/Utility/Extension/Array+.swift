//
//  Array+.swift
//  DataSource
//
//  Created by Yuki Okudera on 2021/12/30.
//

import Foundation

extension Array {
    subscript (safe index: Index) -> Element? {
        return indices.contains(index) ? self[index] : nil
    }
}
