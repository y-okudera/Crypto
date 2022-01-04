//
//  OperationState.swift
//  DataSource
//
//  Created by Yuki Okudera on 2021/12/30.
//

import Foundation

enum OperationState {
    case new
    case dataDownloaded
    case dataEncrypted
    case writtenToFile
    case failed
}
