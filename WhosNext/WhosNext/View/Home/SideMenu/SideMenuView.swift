//
//  SideMenuView.swift
//  WhosNext
//
//  Created by differenz195 on 03/10/22.
//

import SwiftUI


struct ParentFunctionKey: EnvironmentKey {
    static let defaultValue: (() -> Void)? = nil
}

// MARK: - EnvironmentValues
extension EnvironmentValues {
    var parentFunction: (() -> Void)? {
        get { self[ParentFunctionKey.self] }
        set { self[ParentFunctionKey.self] = newValue }
    }
    
    var moveToOtherView: (()-> Void)? {
        get { self[ParentFunctionKey.self] }
        set { self[ParentFunctionKey.self] = newValue }
    }
    
}

// MARK:- Global variable
var sideMenuGlobalVariable = ""

// MARK: - SideMenu View
struct SideMenuView: View {
    @EnvironmentObject var viewRouter : ViewRouter
    @Environment(\.moveToOtherView) var moveToOtherView
    
    @StateObject var sidebarVM: SidebarViewModel
    
    @Binding var isSidebarVisible:Bool
    @State var isShowAlert: Bool = false
    
    var sideBarWidth = ScreenSize.SCREEN_WIDTH * 1
    var arrMenuUser = MenuItem.sideMenuItemUsers()
    var arrMenuAdminUser = MenuItem.sideMenuItemsAdmin()
    var userType = UserDefaults.getData(UserDefaultsKey.kLoginUser, data: UserModel.self)?.userType ?? 1
    var bgColor: Color = Color.myCustomColor
    
    var body: some View {
        ZStack {
            NavigationLink(destination: LoginView(),isActive: self.$sidebarVM.moveToLogin, label: {})
            
            GeometryReader { _ in
                EmptyView()
            }
            .background(Color.black.opacity(0.6))
            .opacity(self.isSidebarVisible ? 1 : 0)
            .animation(.easeInOut.delay(0.2), value: self.isSidebarVisible)
            .onTapGesture {
                self.isSidebarVisible.toggle()
            }
            
            self.content
        }
        .edgesIgnoringSafeArea(.all)
        .hideNavigationBar()
    }
    
    
    var content: some View {
        ZStack {
            self.bgColor
            
            VStack(spacing: 30) {
                Image(IdentifiableKeys.ImageName.kAppTitleText)
                    .frame(height: 50, alignment: .center)
                    .padding(.top, 70)
                    .padding(.horizontal, 35)
                Spacer()
                
                ZStack {
                    ScrollView(.vertical, showsIndicators: false, content: {
                        LazyVStack(alignment: .center) {
                            LazyVStack(alignment: .center, spacing: 5) {
                                if self.userType == 1 {
                                    ForEach(self.arrMenuUser,id: \.self) { item in
                                        MenuCell(iconTitle: item.text, isChangeColor: item.id == 1 ? true : false)
                                            .padding([.all],10)
                                            .onTapGesture {
                                                switch item.id {
                                                    case 0:
                                                        /// `featured profile`
                                                        print("*********** id: \(item.id) and name: \(item.text) ***********")
                                                        sideMenuGlobalVariable = item.text
                                                        self.isSidebarVisible = false
                                                        moveToOtherView?()
                                                    case 1:
                                                        /// `breast cancer legacies`
                                                        print("*********** id: \(item.id) and name: \(item.text) ***********")
                                                        sideMenuGlobalVariable = item.text
                                                        self.isSidebarVisible = false
                                                        moveToOtherView?()
                                                    case 2:
                                                        /// `discover`
                                                        print("*********** id: \(item.id) and name: \(item.text) ***********")
                                                        self.isSidebarVisible = false
                                                        sideMenuGlobalVariable = item.text
                                                        moveToOtherView?()
                                                    case 3:
                                                        /// `home page`
                                                        print("*********** id: \(item.id) and name: \(item.text) ***********")
                                                        self.isSidebarVisible = false
                                                        sideMenuGlobalVariable = item.text
                                                        moveToOtherView?()
                                                    case 4:
                                                        /// `my profile`
                                                        print("*********** id: \(item.id) and name: \(item.text) ***********")
                                                        self.isSidebarVisible = false
                                                        sideMenuGlobalVariable = item.text
                                                        moveToOtherView?()
                                                    case 5:
                                                        /// `messages`
                                                        print("*********** id: \(item.id) and name: \(item.text) ***********")
                                                        self.isSidebarVisible = true
                                                        sideMenuGlobalVariable = item.text
                                                        // moveToOtherView?()
                                                        Alert.show(message: "coming soon!")
                                                    case 6:
                                                        /// `pictures`
                                                        print("*********** id: \(item.id) and name: \(item.text) ***********")
                                                        self.isSidebarVisible = false
                                                        sideMenuGlobalVariable = item.text
                                                        moveToOtherView?()
                                                    case 7:
                                                        /// `videos`
                                                        print("*********** id: \(item.id) and name: \(item.text) ***********")
                                                        self.isSidebarVisible = false
                                                        sideMenuGlobalVariable = item.text
                                                        moveToOtherView?()
                                                    case 8:
                                                        /// `change password`
                                                        print("*********** id: \(item.id) and name: \(item.text) ***********")
                                                        self.isSidebarVisible = false
                                                        sideMenuGlobalVariable = item.text
                                                        moveToOtherView?()
                                                    case 9:
                                                        /// `add snippet`
                                                        print("*********** id: \(item.id) and name: \(item.text) ***********")
                                                        self.isSidebarVisible = false
                                                        sideMenuGlobalVariable = item.text

                                                        self.sidebarVM.getSnippetPermissionApi {
                                                            moveToOtherView?()
                                                        }
                                                    case 10:
                                                        /// `logout`
                                                        print("*********** id: \(item.id) and name: \(item.text) ***********")
                                                        self.isSidebarVisible = true
                                                        sideMenuGlobalVariable = item.text
                                                        Alert.show(message: IdentifiableKeys.AlertMessages.kLogout, isLogOut: true, viewRouter: viewRouter)
                                                    default:
                                                        break
                                                }
                                            }
                                    }
                                } else if self.userType == 0 {
                                    ForEach(self.arrMenuAdminUser, id: \.self) { item in
                                        MenuCell(iconTitle: item.text, isChangeColor: item.id == 1 ? true : false)
                                            .padding([.all],10)
                                            .onTapGesture {
                                                switch item.id {
                                                    case 0:
                                                        /// `featured profile`
                                                        print("*********** id: \(item.id) and name: \(item.text) ***********")
                                                        self.isSidebarVisible = false
                                                        sideMenuGlobalVariable = item.text
                                                         moveToOtherView?()
                                                    case 1:
                                                        /// `breast cancer legacies`
                                                        print("*********** id: \(item.id) and name: \(item.text) ***********")
                                                        self.isSidebarVisible = false
                                                        sideMenuGlobalVariable = item.text
                                                         moveToOtherView?()
                                                    case 2:
                                                        /// `discover`
                                                        print("*********** id: \(item.id) and name: \(item.text) ***********")
                                                        self.isSidebarVisible = false
                                                        sideMenuGlobalVariable = item.text
                                                        moveToOtherView?()
                                                    case 3:
                                                        /// `home page`
                                                        print("*********** id: \(item.id) and name: \(item.text) ***********")
                                                        self.isSidebarVisible = false
                                                        sideMenuGlobalVariable = item.text
                                                        moveToOtherView?()
                                                    case 4:
                                                        /// `my profile`
                                                        print("*********** id: \(item.id) and name: \(item.text) ***********")
                                                        self.isSidebarVisible = false
                                                        sideMenuGlobalVariable = item.text
                                                        moveToOtherView?()
                                                    case 5:
                                                        /// `messaging`
                                                        print("*********** id: \(item.id) and name: \(item.text) ***********")
                                                        self.isSidebarVisible = true
                                                        sideMenuGlobalVariable = item.text
                                                        // moveToOtherView?()
                                                        Alert.show(message: "coming soon!")
                                                    case 6:
                                                        /// `send push notifications`
                                                        print("*********** id: \(item.id) and name: \(item.text) ***********")
                                                        self.isSidebarVisible = true
                                                        sideMenuGlobalVariable = item.text
                                                        // moveToOtherView?()
                                                        Alert.show(message: "coming soon!")
                                                    case 7:
                                                        /// `pictures`
                                                        print("*********** id: \(item.id) and name: \(item.text) ***********")
                                                        self.isSidebarVisible = false
                                                        sideMenuGlobalVariable = item.text
                                                        moveToOtherView?()
                                                    case 8:
                                                        /// `videos`
                                                        print("*********** id: \(item.id) and name: \(item.text) ***********")
                                                        self.isSidebarVisible = false
                                                        sideMenuGlobalVariable = item.text
                                                        moveToOtherView?()
                                                    case 9:
                                                        /// `change password`
                                                        print("*********** id: \(item.id) and name: \(item.text) ***********")
                                                        self.isSidebarVisible = false
                                                        sideMenuGlobalVariable = item.text
                                                        moveToOtherView?()
                                                    case 10:
                                                        /// `city`
                                                        print("*********** id: \(item.id) and name: \(item.text) ***********")
                                                        self.isSidebarVisible = false
                                                        sideMenuGlobalVariable = item.text
                                                        moveToOtherView?()
                                                    case 11:
                                                        /// `category`
                                                        print("*********** id: \(item.id) and name: \(item.text) ***********")
                                                        self.isSidebarVisible = false
                                                        sideMenuGlobalVariable = item.text
                                                        moveToOtherView?()
                                                    case 12:
                                                        /// `add new snippet`
                                                        print("*********** id: \(item.id) and name: \(item.text) ***********")
                                                        self.isSidebarVisible = false
                                                        sideMenuGlobalVariable = item.text

                                                        self.sidebarVM.getSnippetPermissionApi {
                                                            moveToOtherView?()
                                                        }
                                                    case 13:
                                                        /// `snippet list`
                                                        print("*********** id: \(item.id) and name: \(item.text) ***********")
                                                        self.isSidebarVisible = false
                                                        sideMenuGlobalVariable = item.text
                                                         moveToOtherView?()
                                                    case 14:
                                                        /// `snippet upload access request`
                                                        print("*********** id: \(item.id) and name: \(item.text) ***********")
                                                        self.isSidebarVisible = false
                                                        sideMenuGlobalVariable = item.text
                                                        moveToOtherView?()
                                                    case 15:
                                                        /// `logout`
                                                        print("*********** id: \(item.id) and name: \(item.text) ***********")
                                                        self.isSidebarVisible = true
                                                        sideMenuGlobalVariable = item.text
                                                        Alert.show(message: IdentifiableKeys.AlertMessages.kLogout, isLogOut: true)
                                                    default:
                                                        break
                                                }
                                            }
                                    }
                                }
                            }
                            .frame(maxWidth: .infinity)
                            
                            Spacer(minLength: 20.0)
                        }
                    })
                }
            }
        }
        .gesture(DragGesture(minimumDistance: 10, coordinateSpace: .global)
            .onEnded({ value in
                withAnimation {
                    if value.translation.width < ScreenSize.SCREEN_WIDTH {
                        self.isSidebarVisible.toggle()
                    }
                }
            }))
        .frame(width: self.sideBarWidth)
        .offset(x: self.isSidebarVisible ? 0 : -self.sideBarWidth)
        .animation(.default, value: self.isSidebarVisible)
        .onAppear(perform: {
            UIScrollView.appearance().bounces = false
        })
        .ignoresSafeArea(.all)
        
    }
}

