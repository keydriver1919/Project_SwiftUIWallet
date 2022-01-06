//
//  PaymentDetailViewModel.swift
//  PFinance
//
//  Created by change on 13/6/2021.
//

//在視圖模型中實現邏輯轉換
import Foundation

struct PaymentDetailViewModel {
    
    var payment: PaymentActivity
    init(payment: PaymentActivity) {
        self.payment = payment
    }
    
    var name: String {
        return payment.name
    }
    
    //邏輯轉換為Date型別中，轉換為String日期的方法.string()
    var date: String {
        return payment.date.string()
    }
    
    //邏輯轉換內容為：二元運算子，數據庫數據or空值
    var address: String {
        return payment.address ?? ""
    }
    
    //依照表單模型的type屬性的選擇，進行圖示String的變化
    var typeIcon: String {
        
        let icon: String
        
        switch payment.type {
        case .income: icon = "arrowtriangle.up.circle.fill"
        case .expense: icon = "arrowtriangle.down.circle.fill"
        }
        
        return icon
    }
    
    //傳入圖片
    var image: String = "payment-detail"
    
    
    
    // 設定一個將數字格式化功能的屬性，並將其設為十進制，到第一分位
    var amount: String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.minimumFractionDigits = 0
        
        //進行資料格式的轉換，將在CoreData裡的NS資料類型，轉換為String
        let formattedValue = formatter.string(from: NSNumber(value: payment.amount)) ?? ""
        //由視圖模型中的type屬性，透過三元運算子判斷是支出還是收入，以此判斷總收支的正負數值，並回傳
        let formattedAmount = ((payment.type == .income) ? "+" : "-") + "$" + formattedValue
        
        return formattedAmount
    }
    
    //邏輯轉換內容為：二元運算子，數據庫數據or空值
    var memo: String {
        return payment.memo ?? ""
    }
    
    //建構表單模型


}

