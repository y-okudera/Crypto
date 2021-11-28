//
//  ExceptionCatchable.swift
//  DataSource
//
//  Created by Yuki Okudera on 2021/11/28.
//

import Foundation

protocol ExceptionCatchable {}

extension ExceptionCatchable {
    func execute(_ tryBlock: () -> ()) throws {
        try ExceptionHandler.catchException(try: tryBlock)
    }
}
