//
//  BottomSheet.swift
//  SwiftUIWallet
//
//  Created by change on 14/6/2021.
//

import SwiftUI


//底單套件

//定義一個列舉來表示拖曳的狀態
enum DragState {
    case inactive//靜止
    case pressing//按下
    case dragging(translation: CGSize)//拉動
    
    
    //這個變數是用來判斷DragState的狀況
    var translation: CGSize {
        switch self {
        case .inactive, .pressing:
            return .zero//如果translation是0，則代表CGSize沒變，代表按下或靜止
        case .dragging(let translation):
            return translation//如果translation是CGsize值，回傳偏移量的話，代表有拉動
        }
    }
    
    //這個變數是用來判斷是否在拖曳中，拉動是有在拖曳中，按下和靜止都是沒有拖曳中
    var isDragging: Bool {
        switch self {
        case .dragging:
            return true
        case .inactive, .pressing:
            return false
        }
    }
    
}



struct BottomSheet<Content>: View where Content: View  {
    
    //用來判斷全開及半開的列舉
    enum ViewState {
        case full
        case half
    }
    
    @GestureState private var dragState = DragState.inactive
    //宣告一個手勢狀態綁定變數，追蹤拖曳狀態，預設為靜止，回傳值是0
    @State private var positionOffset: CGFloat = 0.0
    //宣告一個狀態綁定變數，追蹤底單的位置偏移量
    @State private var viewState = ViewState.half
    //宣告一狀態綁定變數，預設為半開
    @State private var scrollOffset: CGFloat = 0.0
    //宣告一追蹤滾動偏移量的狀態綁定變數，預設值為0
    @Binding var isShow: Bool
    //用來代表”是否顯示“底單的綁定變量
    let content: () -> Content
    //content屬性傳入一回傳值為View的閉包
    
    
    var body: some View {
        GeometryReader { geometry in
            VStack {
                Spacer()
                HandleBar()
                //為了讓細項視圖能完整顯示，使用ScrollView
                ScrollView(.vertical) {
                    
            //他會抓取付視圖的滾動量，因而將自己增長
                //GeometryReader 的閉包中，我們可以使用 scrollViewProxy，呼叫 frame 函數並取得父視圖的滾動量，minY的值來計算偏移量
                    //使用Color clear來隱藏視圖，存儲在偏好，
                    GeometryReader { scrollViewProxy in
                        Color.clear.preference(key: ScrollOffsetKey.self, value: scrollViewProxy.frame(in: .named("scrollview")).minY)
                    }
                    .frame(height: 0)
                   self.content()
                }
                .background(Color("BdWhite"))
                .cornerRadius(30, antialiased: true)
                .disabled(self.viewState == .half)       //半開時禁用ScrollView
                .coordinateSpace(name: "scrollview")    //滾動座標空間
            }
            //底單的高度
            //修改 VStack 的 .offset 修飾器來移動細節視圖：
            //在閉包中，我們可以使用 geometry 參數來存取父視圖的大小，這就是為什麼我們設定 offset 修飾器如下：
            //以下為細節視圖下移量，螢幕高的一半，加上自身的拖曳偏移量，再加上底單原本的偏移量
            .offset(y: geometry.size.height/2 + self.dragState.translation.height + self.positionOffset)
            //.offset(y: self.scrollOffset)//此偏移量為追蹤的滾動偏移量
            //設定底單的向上彈入動畫
            .animation(.interpolatingSpring(stiffness: 200.0, damping: 25.0, initialVelocity: 10.0))
            //要正確計算全螢幕的尺寸，我們加入 edgesIgnoringSafeArea修飾器，並設定其參數為 .all，以完全忽略安全區域。
            .edgesIgnoringSafeArea(.all)
            //從佈局偏好取得滾動視圖，使用 .onPreferenceChange 來觀察偏移量的變更
            //當滾動偏移量有變化時，我們檢查他是否超過我們的界限值（ 120 ），偏移量不小於0，超過退回半開 .half
            //ScrollOffsetKey為總和父視圖的偏移量
            .onPreferenceChange(ScrollOffsetKey.self) { value in
                if self.viewState == .full {
                    self.scrollOffset = value > 0 ? value : 0
                    if self.scrollOffset > 120 {
                        self.positionOffset = 0
                        self.viewState = .half
                        self.scrollOffset = 0
                    }
                }
            }
            
            //為了支援拖曳手勢
            //在updating 函數中，我們只使用最新的拖曳資料來更新 dragState 屬性。
            .gesture(DragGesture()
                        //用最新的拖曳資料更新 dragState 屬性
                .updating(self.$dragState, body: { (value, state, transaction) in
                    state = .dragging(translation: value.translation)
                    
                    })
                        //當拖曳結束時，SwiftUI 會自動呼叫 onEnded 函數
                .onEnded({ (value) in
                    if self.viewState == .half {
                        // 向上滑動，當它超過界限值"往上屏高0.25"時，變為預設的一個高度，然後將開合狀態修改
            
                        if value.translation.height < -geometry.size.height * 0.25 {
                            self.positionOffset = -geometry.size.height/2 + 50
                            self.viewState = .full
                        }
                        // 向下滑動，超過向下屏高0.3界限值，關閉視圖
                        if value.translation.height > geometry.size.height * 0.3 {
                            self.isShow = false
                        }
                    }
                })
            )
        }
    }
}


struct BottomSheet_Previews: PreviewProvider {
    static var previews: some View {
        BottomSheet(isShow: .constant(true)) {
            Text("Payment Details")
        }
        .background(Color.black.opacity(0.3))
        .edgesIgnoringSafeArea(.all)
    }
}

//抬頭Bar：放在底單的開頭處
struct HandleBar: View {
    
    var body: some View {
        Rectangle()
            .frame(width: 50, height: 5)
            .foregroundColor(Color(.systemGray5))
            .cornerRadius(10)
    }
}

//用來傳遞滾動的偏移量
//從子視圖傳遞資料到父視圖的協定
//PreferenceKey這個協定有兩個必要的實作內容。
struct ScrollOffsetKey: PreferenceKey {
    //自定義一個為CGFloat的屬性
    typealias Value = CGFloat
    //1. 必須定義預設值
    static var defaultValue = CGFloat.zero
    //2. 必須實作 reduce 函數，將所有偏移量值合併成一個回傳值。
    //inout 從外部叫進來Value，總和，預設值加上偏移量
    static func reduce(value: inout Value, nextValue: () -> Value) {
        value += nextValue()
    }
}

