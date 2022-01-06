//
//  PaymentActivity.swift
//  SwiftUIWallet
//
//  Created by change on 11/6/2021.
//

import Foundation
import CoreData


enum PaymentCategory: Int {
    case income = 0
    case expense = 1
}


public class PaymentActivity: NSManagedObject {

    @NSManaged public var paymentId: UUID
    @NSManaged public var date: Date
    @NSManaged public var name: String
    @NSManaged public var address: String?//地點
    @NSManaged public var amount: Double
    @NSManaged public var memo: String?//備註
    @NSManaged public var typeNum: Int32//支付類型
}
//表單分類(收入&支出)
extension PaymentActivity: Identifiable {
    var type: PaymentCategory {
        get {
            return PaymentCategory(rawValue: Int(typeNum)) ?? .expense
        }
        set {
            self.typeNum = Int32(newValue.rawValue)//初始值
        }
    }
}
/*
get這邊使用二元運算子，有值的話回傳0或1，沒值回傳1
set：typeNum的值為傳入值的初始值，也就是0或1
*/
