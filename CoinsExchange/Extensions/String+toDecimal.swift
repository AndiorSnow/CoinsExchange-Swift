//
//  String+toDecimal.swift
//  CoinsExchange
//
//  Created by LMC60018 on 2024/1/29.
//

import Foundation

extension String {
    
    var to5Decimal: String {
        let decimal = self.components(separatedBy: ".")
        guard let first = decimal.first, let last = decimal.last?.prefix(5) else { return self }
        return "$\(first).\(last)"
    }
    
    var to2Decimal: String {
        let decimal = self.components(separatedBy: ".")
        guard let first = decimal.first, let last = decimal.last?.prefix(2) else { return self }
        return "\(first).\(last)"
    }
    
    var to2DecimalUnit: String {
        guard let value = Double(self) else { return "\(self)" }
        let number = value
        let million = number / 1000000
        let billion = number / 1000000000
        let trillion = number / 1000000000000
        
        var money = ""
        var unit = ""
        if trillion >= 1.0 {
            money = "\(trillion * 10 / 10)"
            unit = "trillion"
        } else if billion >= 1.0 {
            money = "\(billion * 10 / 10)"
            unit = "billion"
        } else if million >= 1.0 {
            money = "\(million * 10 / 10)"
            unit = "million"
        } else {
            money = "\(number)"
        }
        
        let decimal = money.components(separatedBy: ".")
        guard let first = decimal.first, let last = decimal.last?.prefix(2) else { return "\(self)" }
        guard let value = Double("\(first).\(last)") else { return "\(self)" }
        return "\(value) \(unit)"
    }
}
