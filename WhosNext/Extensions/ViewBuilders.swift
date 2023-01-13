//
//  ViewBuilders.swift
//  WhosNext
//
//  Created by differenz195 on 12/07/22.


import SwiftUI

//MARK: - NavigationBar
struct NavigationBarModifier: ViewModifier {

    var backgroundColor: UIColor?
//    var titleColor: UIColor?
//    var font: UIFont?

    init(backgroundColor: UIColor?) {
        self.backgroundColor = backgroundColor
        let coloredAppearance = UINavigationBarAppearance()
        coloredAppearance.configureWithTransparentBackground()
        coloredAppearance.backgroundColor = backgroundColor
//        coloredAppearance.titleTextAttributes = [.foregroundColor: titleColor ?? .white, .font: font]
//        coloredAppearance.largeTitleTextAttributes = [.foregroundColor: titleColor ?? .white]
        UINavigationBar.appearance().standardAppearance = coloredAppearance
        UINavigationBar.appearance().compactAppearance = coloredAppearance
        UINavigationBar.appearance().scrollEdgeAppearance = coloredAppearance
        
    }

    func body(content: Content) -> some View {
        ZStack{
            content
            VStack {
                GeometryReader { geometry in
                    Color(self.backgroundColor ?? .clear)
                        .frame(height: geometry.safeAreaInsets.top)
                        .edgesIgnoringSafeArea(.top)
                    Spacer()
                }
            }
        }
    }
}
//MARK: - Draggable View
struct DraggableView: ViewModifier {
    @State var offset = CGPoint(x: 0, y: 0)
    
    func body(content: Content) -> some View {
        content
            .gesture(DragGesture(minimumDistance: 0)
                     
                .onChanged { value in
                    self.offset.x += value.location.x - value.startLocation.x
                    self.offset.y += value.location.y - value.startLocation.y
                })
        
            .offset(x: offset.x, y: offset.y)
    }
}

//MARK: - SearchBar
struct SearchBar: View {
    
    @Binding var searchText: String
    var isShowCancelBtn : Bool = false

    var body: some View {
        
    
        HStack(spacing: 0) {
            Button(action: {
                
            }, label: {
                Image(IdentifiableKeys.ImageName.kBlackSearch)
                    .resizable()
                    .frame(width: 20,height: 20)
                    .padding(.leading, 10)
            })
            
            TextField("Search", text: $searchText)
                .textInputAutocapitalization(.never)
//                .autocorrectionDisabled(true)
//                .textCase(.lowercase)
                .padding()
    
            if isShowCancelBtn == true {
                Button(action: {
                    
                }, label: {
                    Image(IdentifiableKeys.ImageName.kCancel)
                        .resizable()
                        .frame(width: 20,height: 20)
                        .padding(.leading, 10)
                })
                .padding(.trailing, 15)
            }
        }
        // .foregroundColor(Color.myDarkCustomColor)
        .frame(height: 40)
        .background(Color.myCustomColor)
        .cornerRadius(10)
        
    }
}



// MARK: - ViewDidLoad
struct ViewDidLoadModifier: ViewModifier {

    @State private var didLoad = false
    private let action: (() -> Void)?

    init(perform action: (() -> Void)? = nil) {
        self.action = action
    }

    func body(content: Content) -> some View {
        content.onAppear {
            if didLoad == false {
                didLoad = true
                action?()
            }
        }
    }
}
//MARK: - Custom Alert
struct MyCustomAlert<Content: View>: View {
    
    let content: Content
    @Binding var show: Bool
    
    init(show: Binding<Bool>, @ViewBuilder content:  () -> Content) {
        self._show = show
        self.content = content()
    }
    
    var body: some View {

        if self.show {
            ZStack {
                Color.black.opacity(0.3)
                VStack {
                    self.content
                }
                .background(Color.white)
                .cornerRadius(15)
                .padding()
            }
            .edgesIgnoringSafeArea(.all)
        }
    }
}

// MARK: - CustomAlert
struct CustomAlert<DialogContent: View>: ViewModifier {
    @Binding var show: Bool
    let dialogContent: DialogContent

    init(isShowing: Binding<Bool>,
         @ViewBuilder dialogContent: () -> DialogContent) {
        self._show = isShowing
        self.dialogContent = dialogContent()
    }

    func body(content: Content) -> some View {
        ZStack {
            content
            if self.show {
                ZStack {
                    Color.black.opacity(0.3)
                    .ignoresSafeArea()
                    
                    VStack {
                        self.dialogContent
                    }
                    .background(Color.white)
                    .cornerRadius(16)
                    .padding()
                    .padding()
                }
            }
        }
    }
}

// MARK: - CommonButtonStyle
struct CommonButtonStyle: ButtonStyle {
    let backgroundColor: Color
    let foregroundColor: Color
    let isDisabled: Bool
    var cornerRadius : CGFloat = 16
    var fontsize : CGFloat =  16
    var fontStyle : Constant.FontStyle = .Regular

    func makeBody(configuration: Self.Configuration) -> some View {
        let currentForegroundColor = self.isDisabled || configuration.isPressed ? self.foregroundColor.opacity(0.3) : self.foregroundColor

        return configuration.label
            .padding()
            .foregroundColor(currentForegroundColor)
            .background(self.isDisabled || configuration.isPressed ? self.backgroundColor.opacity(0.3) : self.backgroundColor)
            .cornerRadius(self.cornerRadius)
            .font(.setFont(style: self.fontStyle, size: self.fontsize))
    }
}

// MARK: - Indicator
struct Indicator {
    static func show()  { NotificationCenter.default.post(name: .showIndicator, object: true) }
    static func hide() {  NotificationCenter.default.post(name: .showIndicator, object: false) }
}

// MARK: - ActivityIndicatorExt
struct ActivityIndicatorExt: ViewModifier {
    var show: Bool
    func body(content: Content) -> some View {
        ZStack {
            content
            if show {
                Color.black.opacity(0.3)
                    .ignoresSafeArea()
                ProgressView()
                    .foregroundColor(.white)
                    .padding(20)
                    .background(Color.myCustomColor.opacity(0.9))
                    .cornerRadius(15)
            }
        }
    }
}
