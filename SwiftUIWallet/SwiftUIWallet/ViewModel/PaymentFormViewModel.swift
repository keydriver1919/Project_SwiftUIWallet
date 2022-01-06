//
//  PaymentFormViewModel.swift
//  PFinance
//
//  Created by change on 13/6/2021.
//

import Foundation
import Combine

class PaymentFormViewModel: ObservableObject {

    // Input 數據傳入
    @Published var name = ""
    @Published var location = ""
    @Published var amount = ""
    @Published var type = PaymentCategory.expense
    @Published var date = Date.today
    @Published var memo = ""
    
    // Output 狀態刷新
    @Published var isNameValid = false
    @Published var isAmountValid = true
    @Published var isMemoValid = true
    @Published var isFormInputValid = false
    
    //取消訂閱時可以使用的cancellableSet，型別為雜湊的合集
    //assign函數建立訂閱者，並回傳一個可取消的實例cancellableSet，store
    //函數可讓我們將可取消的的參照儲存到一個集合中，以便稍後的清理。
    private var cancellableSet: Set<AnyCancellable> = []
    
    //初始化訂閱者來監聽文字欄位的值的變更，並執行相應的驗證。
    //初始化傳入的訂閱者為：表單模型的屬性們
    init(paymentActivity: PaymentActivity?) {
        
        self.name = paymentActivity?.name ?? ""
        self.location = paymentActivity?.address ?? ""
        self.amount = "\(paymentActivity?.amount ?? 0)"
        self.memo = paymentActivity?.memo ?? ""
        self.type = paymentActivity?.type ?? .expense
        self.date = paymentActivity?.date ?? Date.today
        /*Combine 框架提供兩個內建的訂閱者：
         「sink」：sink 建立一個通用訂閱者來接收值
         「assign」：assign ，用於更新物件的特定屬性，它將驗證結果（true/false ）指定給isNameValid
        
        $監聽 name 的變化。
        驗證使用者名稱與回傳驗證結果（true/false）。
        指定結果至 isNameValid。*/
        $name
            //呼叫 receive(on:) 函數來確保訂閱者在主執行緒（即 RunLoop.main ）上接收到值。
            .receive(on: RunLoop.main)
            //Combine中的運算子map，找出name，將name作為輸入，並確認驗證結果是否成立，並回傳給isNameValid要大於一個字元。
            .map { name in
                return name.count > 0
            }
            //assign函數建立訂閱者，並回傳一個可取消的實例，用來取消訂閱。store 函數可讓我們將可取消的的參照儲存到一個集合中，以便稍後可進行的清理。
            .assign(to: \.isNameValid, on: self)
            .store(in: &cancellableSet)
                        
        $amount
            .receive(on: RunLoop.main)
            .map { amount in
                guard let validAmount = Double(amount) else {
                    return false
                }
                return validAmount > 0
            }
            .assign(to: \.isAmountValid, on: self)
            .store(in: &cancellableSet)
        
        $memo
            .receive(on: RunLoop.main)
            .map { memo in
                return memo.count > 1
            }
            .assign(to: \.isMemoValid, on: self)
            .store(in: &cancellableSet)
        
        
        //確認部分要同時驗證三個都要成立，然後將驗證結果傳給isFormInputValid
        Publishers.CombineLatest3($isNameValid, $isAmountValid, $isMemoValid)
            .receive(on: RunLoop.main)
            .map { (isNameValid, isAmountValid, isMemoValid) in
                return isNameValid && isAmountValid && isMemoValid
            }
            .assign(to: \.isFormInputValid, on: self)
            .store(in: &cancellableSet)
    }
    
}
