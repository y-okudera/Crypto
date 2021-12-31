//
//  WriteFileOperatorProviderKey.swift
//  DataSource
//
//  Created by Yuki Okudera on 2021/12/31.
//

import Foundation

private struct WriteFileOperatorProviderKey: InjectionKey {
    static var currentValue: WriteFileOperatorProviding = WriteFileOperator()
}

extension InjectedValues {
    public var writeFileOperatorProvider: WriteFileOperatorProviding {
        get { Self[WriteFileOperatorProviderKey.self] }
        set { Self[WriteFileOperatorProviderKey.self] = newValue }
    }
}
