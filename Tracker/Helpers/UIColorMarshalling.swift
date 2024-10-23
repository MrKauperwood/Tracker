//
//  UIColorMarshalling.swift
//  Tracker
//
//  Created by Aleksei Bondarenko on 3.10.2024.
//

import Foundation
import UIKit

final class UIColorMarshalling {
    func hexString(from color: UIColor) -> String {
        let components = color.cgColor.components
        let r: CGFloat = components?[0] ?? 0.0
        let g: CGFloat = components?[1] ?? 0.0
        let b: CGFloat = components?[2] ?? 0.0
        return String.init(
            format: "%02lX%02lX%02lX",
            lroundf(Float(r * 255)),
            lroundf(Float(g * 255)),
            lroundf(Float(b * 255))
        )
    }
    
    func color(from hex: String) -> UIColor {
        var rgbValue: UInt64 = 0
        let scanner = Scanner(string: hex)
        
        // Сканируем строку в rgbValue
        if scanner.scanHexInt64(&rgbValue) {
            return UIColor(
                red: CGFloat((rgbValue & 0xFF0000) >> 16) / 255.0,
                green: CGFloat((rgbValue & 0x00FF00) >> 8) / 255.0,
                blue: CGFloat(rgbValue & 0x0000FF) / 255.0,
                alpha: 1.0
            )
        }
        
        // Если строка некорректна, возвращаем цвет по умолчанию (например, черный)
        return UIColor.black
    }
}
