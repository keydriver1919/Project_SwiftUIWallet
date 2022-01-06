//
//  PaymentFormView.swift
//  SwiftUIWallet
//
//  Created by change on 13/6/2021.
//

import SwiftUI
import CoreData


struct PaymentFormView: View {
    
    //三個屬性
    @Environment(\.managedObjectContext) var context
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    @ObservedObject private var paymentFormViewModel: PaymentFormViewModel
    
    var payment: PaymentActivity?
    init(payment: PaymentActivity? = nil) {
        self.payment = payment
        self.paymentFormViewModel = PaymentFormViewModel(paymentActivity: payment)
    }
    
    var body: some View {
        ScrollView {
            VStack(spacing: 0) {
                // 標題
                Group{
                    HStack(alignment: .lastTextBaseline) {
                        Image(systemName: "pencil")
                        Text("新增記帳")
                            .foregroundColor(Color("Heading"))
                            .font(.system(.largeTitle, design: .rounded))
                            .fontWeight(.black)
                            .padding(.bottom)
                        
                        Spacer()
                        
                        Button(action: {
                            //取消視圖鍵聯
                            self.presentationMode.wrappedValue.dismiss()
                        }) {
                            Image(systemName: "multiply.circle.fill")
                                .font(.title)
                                .foregroundColor(Color("Heading"))
                        }
                    }
                }
                //提示文字
                
                //如果視圖模型的isNameValid驗證成立，就無提示文字，若不成立即顯示驗證錯誤組件。
                
                // 名稱
                FormTextField(name: "名稱", placeHolder: "請輸入您的收支名稱。", value: $paymentFormViewModel.name)
                    .padding(.top)
                if !paymentFormViewModel.isNameValid {
                    ValidationErrorText(text: "請輸入您的收支名稱。").padding(.top)
                }
                // 分類：收入＆支出
                Group{
                    VStack(alignment: .leading) {
                        Text("分類")
                            .foregroundColor(Color("Heading"))
                            .font(.system(.subheadline, design: .rounded))
                            .fontWeight(.bold)
                            .foregroundColor(.primary)
                            .padding(.vertical, 10)
                        
                        HStack(spacing: 0) {
                            Button(action: {
                                self.paymentFormViewModel.type = .income
                            }) {
                                Text("收入")
                                    .font(.headline)
                                    .foregroundColor(self.paymentFormViewModel.type == .income ? Color.white : Color("Heading"))
                            }
                            .frame(minWidth: 0.0, maxWidth: .infinity)
                            .padding()
                            .background(self.paymentFormViewModel.type == .income ? Color("Heading") : Color(.systemBackground))
                            
                            Button(action: {
                                self.paymentFormViewModel.type = .expense
                            }) {
                                Text("支出")
                                    .font(.headline)
                                    .foregroundColor(self.paymentFormViewModel.type == .expense ? Color.white : Color("Heading"))
                            }
                            .frame(minWidth: 0.0, maxWidth: .infinity)
                            .padding()
                            .background(self.paymentFormViewModel.type == .expense ? Color("Heading") : Color(.systemBackground))
                        }
                        .border(Color("Border"), width: 1.0)
                        .cornerRadius(10)
                    }
                }
                
                // 地點
                FormTextField(name: "地點 (選填)", placeHolder: "您在哪裡進行消費？", value: $paymentFormViewModel.location)
                    .padding(.top)
                
                // 日期、金額
                HStack {
                    FormDateField(name: "日期", value: $paymentFormViewModel.date)
                    FormTextField(name: "金額 ($)", placeHolder: "0", value: $paymentFormViewModel.amount)
                }
                .padding(.top)
                
                if !paymentFormViewModel.isAmountValid {
                    ValidationErrorText(text: "請輸入您的日期及收支金額。").padding(.top)
                }
                                // 備忘錄
                FormTextEditor(name: "備註 (選填)", value: $paymentFormViewModel.memo)
                    .padding(.top)
                if !paymentFormViewModel.isMemoValid {
                    ValidationErrorText(text: "可以輸入備註。")
                }
                
                
                // 儲存
                Group{
                    Button(action: {
                        self.save()
                        self.presentationMode.wrappedValue.dismiss()
                    }) {
                        HStack{
                            Image(systemName: "square.and.pencil")
                                .font(.headline)
                            Text("儲存")
                                .fontWeight(.bold)
                                .font(.headline)
                        }
                        .opacity(paymentFormViewModel.isFormInputValid ? 1.0 : 0.8)
                        .foregroundColor(.white)
                        .padding()
                        .frame(minWidth: 0, maxWidth: .infinity)
                        .background(LinearGradient(gradient: Gradient(colors: [Color("TotalBalanceCard"), Color("TotalBalanceCard2")]), startPoint: .leading, endPoint: .trailing))
                        .cornerRadius(15)
                        
                    }
                    .padding()
                    .disabled(!paymentFormViewModel.isFormInputValid)
                }
            }.padding()
        }.onTapGesture  {
            hideKeyboard()
        }//隱藏鍵盤
    }
    
    
    //儲存資料至CoreData
    private func save() {
        //此資料若有新傳入的值就使用，若無就傳入原表單模型（參數脈絡為連接CoreData的參數）
        let newPayment = payment ?? PaymentActivity(context: context)
        
        //以下為設定初始值
        newPayment.paymentId = UUID()
        newPayment.name = paymentFormViewModel.name
        newPayment.type = paymentFormViewModel.type
        newPayment.date = paymentFormViewModel.date
        newPayment.amount = Double(paymentFormViewModel.amount)!
        newPayment.address = paymentFormViewModel.location
        newPayment.memo = paymentFormViewModel.memo
        
        do {
            try context.save()
        } catch {
            print("儲存資料失敗")
            print(error.localizedDescription)
        }
    }
}


//預覽
struct PaymentFormView_Previews: PreviewProvider {
    static var previews: some View {
        
        let context = PersistenceController.shared.container.viewContext
        
        let testTrans = PaymentActivity(context: context)
        testTrans.paymentId = UUID()
        testTrans.name = ""
        testTrans.amount = 0.0
        testTrans.date = .today
        testTrans.type = .expense
        
        return Group {
            PaymentFormView(payment: testTrans)
            PaymentFormView(payment: testTrans)
                .preferredColorScheme(.dark)
            
            FormTextField(name: "名稱", placeHolder: "輸入名稱", value: .constant("")).previewLayout(.sizeThatFits)
            
            ValidationErrorText(text: "請輸入支出名稱。").previewLayout(.sizeThatFits)
            
        }
    }
}

//文字欄位組件
struct FormTextField: View {
    let name: String
    var placeHolder: String
    
    @Binding var value: String
    
    var body: some View {
        
        VStack(alignment: .leading) {
            
            Text(name.uppercased())
                .font(.system(.subheadline, design: .rounded))
                .fontWeight(.bold)
                .foregroundColor(Color("Heading"))
            
            TextField(placeHolder, text: $value)
                .font(.headline)
                .foregroundColor(.primary)
                .padding()
                .border(Color("Border"), width: 1.0)
                .background(Color(.white).opacity(0.85))
                .cornerRadius(10)
        }
        
    }
}

//DataPicker組件
struct FormDateField: View {
    let name: String
    
    @Binding var value: Date
    
    var body: some View {
        VStack(alignment: .leading) {
            Text(name.uppercased())
                .font(.system(.subheadline, design: .rounded))
                .fontWeight(.bold)
                .foregroundColor(Color("Heading"))
            
            DatePicker("", selection: $value, displayedComponents: .date)
                .accentColor(.primary)
                .padding(10)
                .border(Color("Border"), width: 1.0)
                .labelsHidden()
        }
    }
}

//備註欄組件
struct FormTextEditor: View {
    let name: String
    var height: CGFloat = 60.0
    
    @Binding var value: String
    
    var body: some View {
        VStack(alignment: .leading) {
            HStack{
                Image(systemName: "pencil.circle")
                Text(name.uppercased())
                    .font(.system(.subheadline, design: .rounded))
                    .fontWeight(.bold)
                    .foregroundColor(Color("Heading"))
            }
            TextEditor(text: $value)
                .frame(minHeight: height)
                .font(.headline)
                .foregroundColor(.primary)
                .padding()
                .border(Color("Border"), width: 1.0)
                .background(Color(.white).opacity(0.85).cornerRadius(15))
                .onTapGesture  {
                    hideKeyboard()
                }//隱藏鍵盤
        }
    }
}


//驗證錯誤組件
struct ValidationErrorText: View {
    
    var iconName = "info.circle"
    var iconColor = Color(red: 255/255, green: 100/255, blue: 100/255)
    
    var text = ""
    
    var body: some View {
        HStack {
            Image(systemName: iconName)
                .foregroundColor(iconColor)
            Text(text)
                .font(.system(.body, design: .rounded))
                .foregroundColor(.secondary)
            
            Spacer()
        }
    }
}


