//
//  Date+Extension.swift
//  HGF Collective
//
//  Created by William Dolke on 30/09/2022.
//

import Foundation

/// Convert a timestamp to a specified format
extension Date {
    func formattedDateString(format: String? = "MMM d, h:mm a") -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: "en_GB")
        dateFormatter.timeZone = TimeZone(abbreviation: "London")
        dateFormatter.amSymbol = "AM"
        dateFormatter.pmSymbol = "PM"
        dateFormatter.calendar = Calendar(identifier: .gregorian)
        dateFormatter.dateFormat = format

        return dateFormatter.string(from: self)
    }
}
