//
//  DashboardView.swift
//  SwiftUIWallet
//
//  Created by change on 15/6/2021.
//

import SwiftUI
import CoreData

//交易顯示列舉
enum TransactionDisplayType {
    case all
    case income
    case expense
}


//儀表板會用到的屬性、計算屬性、主儀表板
struct DashboardView: View {
    
    //環境變量managedObjectContext：和CoreData物件的聯繫物件
    @Environment(\.managedObjectContext) var context
    @FetchRequest(//FetchRequest獲取請求
        entity: PaymentActivity.entity(),  //實體是表單模型的實體
        sortDescriptors: [ NSSortDescriptor(keyPath: \PaymentActivity.date, ascending: false) ])//NS排序描述，路徑是表單模型的日期，非升冪
    var paymentActivities: FetchedResults<PaymentActivity>//獲取<表單模型>的結果
    
    @State private var showPaymentDetails = false//先設定好顯示細項、編輯細項為false
    @State private var editPaymentDetails = false
    
    //總收入數據計算
    private var totalIncome: Double {
        //paymentActivities為表單模型的集合
        let total = paymentActivities
            .filter {
                //過濾收支活動，$0為陣列鍵
                $0.type == .income
                //計算總合(reduce)，運算從0開始，$0為每次加後的結果，$1為每次新傳的值，一直加到陣列裡全部加完為止
            }.reduce(0) {
                $0 + $1.amount
            }
        return total
    }
    //總支出數據計算
    private var totalExpense: Double {
        let total = paymentActivities
            .filter {
                $0.type == .expense
            }.reduce(0) {
                $0 + $1.amount
            }
        
        return total
    }
    //總平衡數據計算
    private var totalBalance: Double {
        //總收入減去總支出
        return totalIncome - totalExpense
    }
    
    
    //歷遍所有活動
    //為了列出交易，用ForEach循環遍歷支付活動並TransactionCellView為每個活動創建一個
    
    //顯示在螢幕上的表單數據類別
    private var paymentDataForView: [PaymentActivity] {
        
        switch listType {
        case .all:
            return paymentActivities
                //排序方式：降冪，收入日期&支出日期
                //$0為paymentActivities的第一個參數，$1為paymentActivities的第二個參數
                //第一個參數相對於第二個參數，為降冪
                .sorted(by: { $0.date.compare($1.date) == .orderedDescending })
        case .income:
            return paymentActivities
                //過濾為僅收入
                .filter { $0.type == .income }
                .sorted(by: { $0.date.compare($1.date) == .orderedDescending })
        case .expense:
            return paymentActivities
                //過濾為僅支出
                .filter { $0.type == .expense }
                .sorted(by: { $0.date.compare($1.date) == .orderedDescending })
        }
    }
    
    //遵從有三個交易屬性的listType，預設值為all
    @State private var listType: TransactionDisplayType = .all
    //遵從表單模型的屬性selectedPaymentActivity
    @State private var selectedPaymentActivity: PaymentActivity?
    
    @State private var isPressed = false
    
    //主儀表板
    var body: some View {
        ZStack {
            ZStack {
                ScrollView(showsIndicators: false) {
                    
                    MenuBar() {
                        PaymentFormView().environment(\.managedObjectContext, self.context)
                    }
                    .listRowInsets(EdgeInsets())//無邊距離
                    
                    Image("logo").resizable().scaledToFit().frame(width: 100, height: 100, alignment: .center)
                        .shadow(color: .gray, radius: 1, x: 0.0, y: 2)
                        .opacity(isPressed ? 1 : 1).offset(x: 0, y: isPressed ? -2 : 2).animation(.spring(response: 0.3, dampingFraction: 0.3, blendDuration: 0.1))
                        .onTapGesture {
                            self.isPressed.toggle()
                        }
                    
                    VStack{
                        if isPressed{
                            IncomeCard(income: totalIncome)
                            ExpenseCard(expense: totalExpense)
                            //總收支平衡卡
                            TotalBalanceCard(totalBalance: totalBalance)
                        }
                        else{
                            TotalBalanceCard(totalBalance: totalBalance)
                        }
                    } .shadow(color: .gray, radius: 2, x: 0.0, y: 4)
                    
                    
                    
                    //收支顯示標題
                    TransactionHeader(listType: $listType)
                        .padding(.bottom)
                        .animation(.easeOut(duration: 0.3))
                    // 列出收支紀錄
                    ForEach(paymentDataForView) { transaction in
                        TransactionCellView(transaction: transaction)
                            .onTapGesture {
                                self.showPaymentDetails = true
                                self.selectedPaymentActivity = transaction
                            }
                            //SwiftUI中非常方便的修飾符，長按會顯示
                            .contextMenu {
                                Button(action: {
                                    // Edit payment details
                                    self.editPaymentDetails = true
                                    self.selectedPaymentActivity = transaction
                                    
                                }) {
                                    HStack {
                                        Text("編輯")
                                        Image(systemName: "pencil")
                                    }
                                }
                                
                                Button(action: {
                                    self.delete(payment: transaction)
                                }) {
                                    HStack {
                                        Text("刪除")
                                        Image(systemName: "trash")
                                    }
                                }
                            }
                    }
                    //每一個歷遍都會觸發sheet，也就是顯示表單視圖，參數為self.$editPaymentDetails，在按下時，其預設的false即改成true
                    //此部分意思即是按下編輯，就會進入表單視圖，並可進行修改。fullScreenCover
                    .fullScreenCover(isPresented: self.$editPaymentDetails) {
                        PaymentFormView(payment: self.selectedPaymentActivity).environment(\.managedObjectContext, self.context)
                    }
                    .animation(.easeOut(duration: 0.3))
                }
                //點下之後showPaymentDetails會變true，用三元運算將主儀表板y軸在true向上位移。
                .offset(y: showPaymentDetails ? -100 : 0)
                .padding(.horizontal)
                //.animation(.spring(response: 0.3, dampingFraction: 0.3, blendDuration: 0.3))
                //淡出動畫(後方主儀表板的上移的動畫)（記錄變動動畫）
                
                if showPaymentDetails {
                    
                    BlankView(bgColor: .black)
                        .opacity(0.2)
                        .onTapGesture {
                            self.showPaymentDetails = false
                            
                        }
                    PaymentDetailView(isShow: $showPaymentDetails, payment: selectedPaymentActivity!)
                        .animation(.spring(response: 0.3, dampingFraction: 0.3, blendDuration: 0.3))
                        .transition(.asymmetric(insertion: .move(edge: .leading), removal: .opacity))//底單進入動畫
                }
            }
        }
    }
    
    
    
    
    //從數據庫中刪除活動，調用環境變量context的delete函式
    private func delete(payment: PaymentActivity) {
        self.context.delete(payment)
        
        do {
            try self.context.save()
        } catch {
            print("儲存變動失敗: \(error.localizedDescription)")
        }
    }
    
}

//預覽儀表板及儀表板細項
struct DashboardView_Previews: PreviewProvider {
    
    static var previews: some View {
        
        let context = PersistenceController.shared.container.viewContext
        let testTrans = PaymentActivity(context: context)
        testTrans.paymentId = UUID()
        testTrans.name = "測試"
        testTrans.amount = 2000000.0
        testTrans.date = .today
        testTrans.type = .expense
        
        return Group {
            //DashboardView 使用環境變量context
            DashboardView().environment(\.managedObjectContext, context)
            //黑暗模式
            DashboardView().preferredColorScheme(.dark).environment(\.managedObjectContext, context)
            
            //接收任何視圖的MenuBar>表單視圖
            MenuBar() {
                PaymentFormView()
            }
            .previewLayout(.sizeThatFits)//只顯示視圖的範圍
            
            
            TotalBalanceCard().previewLayout(.sizeThatFits)
            
            IncomeCard().previewLayout(.sizeThatFits)
            
            ExpenseCard().previewLayout(.sizeThatFits)
            
            //收支紀錄標題
            TransactionHeader(listType: .constant(.all)).previewLayout(.sizeThatFits)
            //收支細項視圖，參數為表單模型
            TransactionCellView(transaction: testTrans).previewLayout(.sizeThatFits)
        }
    }
}


//Title列卡
//MenuBar是泛型且泛型Content遵從View
//接收任何視圖
struct MenuBar<Content>: View where Content: View {
    //顯示表單：false
    //狀態綁定屬性showPaymentForm
    @State private var showPaymentForm = false
    @State private var isPressed = false
    
    //常數的型別為回傳值為：View的閉包
    let modalContent: () -> Content
    
    var body: some View {
        ZStack(alignment: .trailing) {
            HStack(alignment: .center) {
                
                Spacer()
                
                //記帳標題欄位
                VStack(alignment: .center) {
                    //日期
                    Text(Date.today.string(with: "EEEE, MMM d, yyyy"))
                        .font(.caption)
                        .foregroundColor(.gray)
                    Text("記帳王")
                        .font(.title)
                        .fontWeight(.black)
                        .foregroundColor(Color("Heading"))
                }
                
                Spacer()
            }
            //顯示表單視圖的按鈕
            Button(action: {
                self.showPaymentForm = true
            }) {
                Image(systemName: "plus.circle")
                    .font(.title)
                    .foregroundColor(Color("Heading"))
            }
            //全螢幕的sheet(彈窗) fullScreenCover
            .fullScreenCover(isPresented: self.$showPaymentForm, onDismiss: {
                self.showPaymentForm = false
            }) {
                self.modalContent()
            }
        }
        
    }
}


//收支平衡狀態卡片
struct TotalBalanceCard: View {
    var totalBalance = 0.0
    @State private var isPressed = false
    var body: some View {
        
        ZStack {
            Rectangle()
                .foregroundColor(Color("TotalBalanceCard")).cornerRadius(15)
            
            VStack {
                HStack {
                    Group{
                        Text("收支")
                            .font(.system(.title, design: .rounded))
                            .fontWeight(.black)
                            .foregroundColor(.white)
                        Text(NumberFormatter.currency(from: totalBalance))
                            .font(.system(.title, design: .rounded))
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                            .minimumScaleFactor(0.1)//最小比例
                    }
                }
            }
            
        }
        .frame(height: 80)
        .animation(.easeOut(duration: 0.3))
        .onTapGesture {
            self.isPressed.toggle()
        }
    }
}


//收入卡
struct IncomeCard: View {
    var income = 0.0
    @State private var isPressed = false
    var body: some View {
        
        ZStack {
            Rectangle()
                .foregroundColor(Color("IncomeCard"))
                .cornerRadius(15.0)
            
            VStack {
                HStack{
                    Group{
                        Text("收入")
                            .font(.system(.title, design: .rounded))
                            .fontWeight(.black)
                            .foregroundColor(.white)
                        Text(NumberFormatter.currency(from: income))
                            .font(.system(.title, design: .rounded))
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                            .minimumScaleFactor(0.1)
                    }
                }
            }
            
        }
        .frame(height: 80)
        .gesture(TapGesture().onEnded({self.isPressed.toggle()}))
        .animation(.easeOut(duration: 0.3))
    }
}

//支出卡
struct ExpenseCard: View {
    var expense = 0.0
    @State private var isPressed = false
    
    var body: some View {
        
        ZStack {
            Rectangle()
                .foregroundColor(Color("ExpenseCard"))
                .cornerRadius(15.0)
            
            VStack {
                HStack{
                    Group{
                        Text("支出")
                            .font(.system(.title, design: .rounded))
                            .fontWeight(.black)
                            .foregroundColor(.white)
                            .fixedSize()
                        Text(NumberFormatter.currency(from: expense))
                            .font(.system(.title, design: .rounded))
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                            .minimumScaleFactor(0.1)
                    }
                }
            }
            
        }
        .frame(height: 80)
        .gesture(TapGesture().onEnded({self.isPressed.toggle()}))
        .animation(.easeOut(duration: 0.3))
    }
}


//收支記錄顯示Header卡
struct TransactionHeader: View {
    @Binding var listType: TransactionDisplayType
    
    var body: some View {
        VStack {
            HStack {
                Image(systemName: "pencil")
                    .foregroundColor(Color("Heading"))
                Text("收支紀錄")
                    .font(.headline)
                    .foregroundColor(Color("Heading"))
                Spacer()
                Group {
                    Text("全部")
                        .padding(3)
                        .padding(.horizontal, 10)
                        .background(listType == .all ? Color("PrimaryButton") : Color("SecondaryButton"))
                        .onTapGesture {
                            self.listType = .all
                        }
                    
                    Text("收入")
                        .padding(3)
                        .padding(.horizontal, 10)
                        .background(listType == .income ? Color("PrimaryButton") : Color("SecondaryButton"))
                        .onTapGesture {
                            self.listType = .income
                        }
                    
                    Text("支出")
                        .padding(3)
                        .padding(.horizontal, 10)
                        .background(listType == .expense ? Color("PrimaryButton") : Color("SecondaryButton"))
                        .onTapGesture {
                            self.listType = .expense
                        }
                }
                .font(.system(.subheadline, design: .rounded))
                .foregroundColor(.white)
                .cornerRadius(15)
            }
            .padding(.top, 10)
        }
    }
}


//收支記錄的細項卡
struct TransactionCellView: View {
    
    @ObservedObject var transaction: PaymentActivity
    
    var body: some View {
        
        HStack(spacing: 10) {
            
            if transaction.isFault {
                EmptyView()
                
            }  else {
                
                //判斷是收入還是支出的圖片
                Image(systemName: transaction.type == .income ? "arrowtriangle.up.circle.fill" : "arrowtriangle.down.circle.fill")
                    .font(.title)
                    .foregroundColor(Color(transaction.type == .income ? "IncomeCard" : "ExpenseCard"))
                
                VStack(alignment: .leading) {
                    Text(transaction.name)
                        .font(.system(.body, design: .rounded))
                    Text(transaction.date.string())
                        .font(.system(.caption, design: .rounded))
                        .foregroundColor(.gray)
                }
                
                Spacer()
                
                Text((transaction.type == .income ? "+" : "-") + NumberFormatter.currency(from: transaction.amount))
                    .font(.system(.headline, design: .rounded))
            }
        }
        .padding(.vertical, 5)
        
    }
}


