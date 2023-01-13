//
//  FollowRequestView.swift
//  WhosNext
//
//  Created by differenz240 on 11/01/23.
//

import SwiftUI

struct FollowRequestView: View {
    @Environment(\.presentationMode) private var presentationMode: Binding<PresentationMode>

    @StateObject private var followersVM: FollowersViewModel = FollowersViewModel()

    var body: some View {
        ScrollView(showsIndicators: false) {
            LazyVStack {
                ForEach(self.$followersVM.followRequestList) { $followRequest in
                    VStack {
                        HStack {
                            Text(followRequest.username ?? "")
                                .font(.custom(Constant.FontStyle.Bold.rawValue, size: Constant.FontSize._14FontSize))
                            
                            Spacer()
                            
                            HStack(spacing: 12.0) {
                                Button(action: {
                                    self.followersVM.acceptRejectRequestApi(userID: "\(followRequest.followID ?? 0)", followType: "2") {
                                        self.followersVM.getFollowRequestList()
                                    }
                                }, label: {
                                    Text("Accept ✓")
                                        .font(.custom(Constant.FontStyle.Regular.rawValue, size: Constant.FontSize._16FontSize))
                                        .padding(.all, 5)
                                })
                                .frame(height: 25)
                                .background(Color.blue.opacity(0.1))
                                .cornerRadius(10)
                                .tint(.blue)
                                
                                Button(action: {
                                    self.followersVM.acceptRejectRequestApi(userID: "\(followRequest.followID ?? 0)", followType: "3") {
                                        self.followersVM.getFollowRequestList()
                                    }
                                }, label: {
                                    HStack {
                                        Text("Reject")
                                            .font(.custom(Constant.FontStyle.Regular.rawValue, size: Constant.FontSize._16FontSize))
                                            .padding(.leading, 3)
                                            .layoutPriority(1)

                                        Text("❌")
                                            .padding(.trailing, 5)
                                            .frame(height: 10)
                                            .scaleEffect(0.7)
                                    }
                                })
                                .frame(height: 25)
                                .background(Color.red.opacity(0.1))
                                .cornerRadius(10)
                                .tint(.red)
                            }
                        }
                        
                        RoundedRectangle(cornerRadius: 0)
                            .frame(height: 1.5)
                            .foregroundColor(Color.appSnippetsColor)
                    }
                    .padding(.all, 12.0)
                }
            }
        }
        .padding(.top, 8.0)
        .navigationBarBackButtonHidden(true)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                HStack {
                    Button(action: {
                        self.presentationMode.wrappedValue.dismiss()
                    }, label: {
                        Image(IdentifiableKeys.ImageName.kBackArrowBlack)
                    })
                    
                    Text(IdentifiableKeys.NavigationbarTitles.kFollowRequest)
                        .foregroundColor(Color.myDarkCustomColor)
                        .font(.custom(Constant.FontStyle.Heavy.rawValue, size: Constant.FontSize._28FontSize))
                }
            }
        }
        .onAppear {
            self.followersVM.getFollowRequestList()
        }
    }
}

// MARK: - Previews
struct FollowRequestView_Previews: PreviewProvider {
    static var previews: some View {
        FollowRequestView()
    }
}
