//
//  WeekdayTransformer.swift
//  Tracker
//
//  Created by Aleksei Bondarenko on 8.10.2024.
//

import Foundation

@objc(StringArrayTransformer)
final class WeekdayTransformer: ValueTransformer {
    
    override class func transformedValueClass() -> AnyClass {
        return NSData.self
    }
    
    override func transformedValue(_ value: Any?) -> Any? {
        guard let array = value as? [String] else { return nil }
        do {
            return try NSKeyedArchiver.archivedData(withRootObject: array, requiringSecureCoding: false)
        } catch {
            print("Failed to encode string array: \(error)")
            return nil
        }
    }
    
    override func reverseTransformedValue(_ value: Any?) -> Any? {
        guard let data = value as? Data else { return nil }
        do {
            return try NSKeyedUnarchiver.unarchivedObject(ofClass: NSArray.self, from: data) as? [String]
        } catch {
            print("Failed to decode string array: \(error)")
            return nil
        }
    }
}

