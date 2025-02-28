//
//  UIColor+colorWithHex.swift
//  CoinsExchange
//
//  Created by LMC60018 on 2024/1/24.
//

import Foundation
import UIKit

extension UIColor {
    convenience init(rgb: UInt) {
        let r, g, b: UInt32
        r = UInt32((rgb & 0xFF0000) >> 16)
        g = UInt32((rgb & 0xFF00) >> 8)
        b = UInt32(rgb & 0xFF)
        self.init(red: CGFloat(r) / 255, green: CGFloat(g) / 255, blue: CGFloat(b) / 255, alpha: 1.0)
   }
}
