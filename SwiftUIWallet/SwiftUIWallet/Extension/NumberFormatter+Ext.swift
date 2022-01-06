//
//  NumberFormatter+Ext.swift
//  SwiftUIWallet
//
//  Created by change on 11/6/2021.
//

import Foundation

//格式化數量
//此函數接收一個值，將其轉換為字符串並在其後附加美元符號。


extension NumberFormatter {
    static func currency(from value: Double) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        
        let formattedValue = formatter.string(from: NSNumber(value: value)) ?? ""
        
        return "$" + formattedValue
    }
}
