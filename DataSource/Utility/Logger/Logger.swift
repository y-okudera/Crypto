//
//  Print.swift
//  DataSource
//
//  Created by Yuki Okudera on 2021/11/14.
//

import Foundation

func log(
    _ items: Any...,
    separator: String = " ",
    terminator: String = "\n",
    function: String = #function,
    file: String = #file,
    line: Int = #line
) {
#if DEBUG
    let now = Df.shared.dateFormatter.string(from: Date())
    var filename = file
    if let match = filename.range(of: "[^/]*$", options: .regularExpression) {
        filename = String(filename[match])
    }
    let header = "\(now) \(function) @\(filename)(L \(line))"

    Swift.print(header, items, separator: separator, terminator: terminator)
#endif
}

private class Df {

    static let shared = Df()
    let dateFormatter: DateFormatter

    private init() {
        dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: "en_US_POSIX")
        dateFormatter.dateFormat = "yyyy/MM/dd HH:mm:ss:SSS"
    }
}
