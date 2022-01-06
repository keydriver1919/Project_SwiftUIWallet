//
//  Date+Ext.swift
//  SwiftUIWallet
//
//  Created by change on 11/6/2021.
//

import Foundation
import SwiftUI


//增加隱藏鍵盤方法
extension View {
    func hideKeyboard() {
        UIApplication.shared.sendAction(
            #selector(UIResponder.resignFirstResponder),
            to: nil,
            from: nil,
            for: nil
        )
    }
}


//日期的預設邏輯
extension Date {
    static var today: Date {
        return Date()
    }
    
    static var yesterday: Date {
        return Calendar.current.date(byAdding: .day, value: -1, to: Date())!
    }
    
    static var tomorrow: Date {
        return Calendar.current.date(byAdding: .day, value: 1, to: Date())!
    }
    
    var month: Int {
        return Calendar.current.component(.month, from: self)
    }
    
    static func fromString(string: String, with format: String = "yyyy-MM-dd") -> Date? {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = format
        return dateFormatter.date(from: string)
    }
    
    func string(with format: String = "dd MMM yyyy") -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = format
        return dateFormatter.string(from: self)
    }
}
