//
//  Date+Formatting.swift
//  CleanStore
//
//  Copyright © 2017 Raymond Law. All rights reserved.
//

import Foundation

extension Date {
    private static let dateFormatter: DateFormatter = {
        let rfc3339DateFormatter = DateFormatter()
        rfc3339DateFormatter.locale = Locale(identifier: "en_US_POSIX")
        rfc3339DateFormatter.dateFormat = "yyyy'-'MM'-'dd'T'HH':'mm':'ss'Z'"
        rfc3339DateFormatter.dateStyle = .short
        rfc3339DateFormatter.timeStyle = .none
        return rfc3339DateFormatter
    }()

    func simpleFormat() -> String {
        return Date.dateFormatter.string(from: self)
    }
}
