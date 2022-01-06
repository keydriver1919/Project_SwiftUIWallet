//
//  PaymentDetailView.swift
//  SwiftUIWallet
//
//  Created by change on 13/6/2021.
//

import SwiftUI

struct PaymentDetailView: View {
    
    @Binding var isShow: Bool
    //此為觸發細項視圖的屬性
    
    let payment: PaymentActivity//表單模型
    
    private let viewModel: PaymentDetailViewModel//細項模型
    
    //isShow設置為ture時觸發此細項視圖、
    //細項視圖建構器的參數為：Bool泛型、表單模型
    init(isShow: Binding<Bool>, payment: PaymentActivity) {
        self._isShow = isShow
        //使用下劃線綁定@Binging的變量
        self.payment = payment
        self.viewModel = PaymentDetailViewModel(payment: payment)
    }
    
    var body: some View {
        BottomSheet(isShow: $isShow) {
            VStack {
                TitleBar(viewModel: self.viewModel)
                
                Image(self.viewModel.image)
                    .resizable()
                    .scaledToFill()
                    .frame(minWidth: 0, maxWidth: .infinity)
                
                // Payment details
                HStack(alignment: .top) {
                    VStack(alignment: .leading, spacing: 2) {
                        Text(self.viewModel.name)
                            .font(.system(.headline))
                            .fontWeight(.semibold)
                        Text(self.viewModel.date)
                            .font(.subheadline)
                            .fontWeight(.semibold)
                            .foregroundColor(Color("Subheadline"))
                        Text(self.viewModel.address)
                            .font(.subheadline)
                            .fontWeight(.semibold)
                            .foregroundColor(Color("Subheadline"))
                            .lineLimit(nil)
                            .multilineTextAlignment(.leading)
                    }
                    .padding(.horizontal)
                    
                    Spacer()
                    
                    VStack(alignment: .trailing) {
                        Text(self.viewModel.amount)
                            .font(.title)
                            .fontWeight(.semibold)
                    }
                    .padding(.trailing)
                }
                Divider()
                    .padding(.horizontal)
                
                if self.viewModel.memo != "" {
                    Group {
                        Text("備註")
                            .font(.subheadline)
                            .bold()
                            .padding(.bottom, 5)
                        
                        Text(self.viewModel.memo)
                            .font(.subheadline)
                        
                        Divider()
                    }
                    .frame(minWidth: 0, maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal)
                    
                }
                
            }
            
        }
    }
}

struct PaymentDetailView_Previews: PreviewProvider {
    static var previews: some View {
        let context = PersistenceController.shared.container.viewContext
        let testTrans = PaymentActivity(context: context)
        testTrans.paymentId = UUID()
        testTrans.name = "買機票喔"
        testTrans.amount = 2000
        testTrans.date = .today
        testTrans.type = .expense
        testTrans.address = "香港王100號"
        testTrans.memo = "飛行專家"
        
        return Group {
            PaymentDetailView(isShow: .constant(true), payment: testTrans)
            PaymentDetailView(isShow: .constant(true), payment: testTrans)
                .preferredColorScheme(.dark)
        }
        .background(Color.primary.opacity(0.3))
        .edgesIgnoringSafeArea(.all)
    }
}

struct TitleBar: View {
    var viewModel: PaymentDetailViewModel
    
    var body: some View {
        HStack {
            Text("收支紀錄")
                .font(.headline)
                .foregroundColor(Color("Heading"))
            
            Image(systemName: viewModel.typeIcon)
                .foregroundColor(Color("ExpenseCard"))
            
            Spacer()
        }
        .padding()
    }
}


