//
//  FollowersCell.swift
//  WhosNext
//
//  Created by differenz195 on 14/10/22.
//

import SwiftUI

struct FollowersCell: View {
    
    //MARK: - Variables
    @State var isShowActionSheet = false
    @State var isFollowingCell: Bool
    private let imageSize: CGFloat = 45
    
    var body: some View {
        if isFollowingCell {
            HStack {
                
                Image(IdentifiableKeys.ImageName.kAvatar)
                    .resizable()
                    .frame(width: imageSize, height: imageSize)
                    .cornerRadius(25)
                
                
                VStack(alignment: .leading){
                    
                    Text("Johny")
                    
                }
                .font(.custom(Constant.FontStyle.Medium
                    .rawValue, size: Constant.FontSize._14FontSize))
                Spacer()
                VStack(alignment: .trailing, spacing: 1){
                    
                    Button(action: {
                        self.isShowActionSheet = true
                        print("select Edit profile")
                        
                    }, label: {
                        
                        Text(IdentifiableKeys.Buttons.kFollowing)
                            .font(.custom(Constant.FontStyle.Medium.rawValue, size: Constant.FontSize._10FontSize))
                            .foregroundColor(Color.white)
                        
                    })
                    
                    .padding(.horizontal, 14)
                    .padding(.vertical, 10)
                    .background(Color.black)
                    .cornerRadius(5)
                    
                }
                .padding(.trailing,15)
                
            }
            
            RoundedRectangle(cornerRadius: 0)
                .frame(height: 1)
                .foregroundColor(Color.CustomColor.AppSnippetsColor)
                .padding(.leading, 5)
            
                .actionSheet(isPresented: self.$isShowActionSheet) { () -> ActionSheet in
                    ActionSheet(title: Text(""), message: Text("Unfollow Johny ?"), buttons: [ActionSheet.Button.destructive(Text(IdentifiableKeys.Buttons.kUnfollow), action: {
                        
                        
                    }), ActionSheet.Button.cancel()])
                    
                }
            
        }
        else {
            HStack {
                
                Image(IdentifiableKeys.ImageName.kAvatar)
                    .resizable()
                    .frame(width: imageSize, height: imageSize)
                    .cornerRadius(25)
                
                
                VStack(alignment: .leading){

                        Text("Johny")
                        Text("started following you.")
                    
                }
                .font(.custom(Constant.FontStyle.Medium
                    .rawValue, size: Constant.FontSize._14FontSize))
                Spacer()
                VStack(alignment: .trailing, spacing: 1){
                    
                    Button(action: {
                        self.isShowActionSheet = true
                        
                    }, label: {
                        
                        Text(IdentifiableKeys.Buttons.kFollowing)
                            .font(.custom(Constant.FontStyle.Medium.rawValue, size: Constant.FontSize._10FontSize))
                            .foregroundColor(Color.white)
                        
                        
                    })
                    
                    .padding(.horizontal, 14)
                    .padding(.vertical, 10)
                    .background(Color.black)
                    .cornerRadius(5)
                    
                }
                .padding(.trailing,15)
                
                
            }
            
            RoundedRectangle(cornerRadius: 0)
                .frame(height: 1)
                .foregroundColor(Color.CustomColor.AppSnippetsColor)
                .padding(.leading, 5)
            
                .actionSheet(isPresented: self.$isShowActionSheet) { () -> ActionSheet in
                                        
                    ActionSheet(title: Text(""), message: Text("If you change your mind, you'll have to request to follow 'johny' again."), buttons: [ActionSheet.Button.destructive(Text(IdentifiableKeys.Buttons.kUnfollow), action: {
                        
                        
                    }), ActionSheet.Button.cancel()])
                }
        }
    }
    
    struct FollowersCell_Previews: PreviewProvider {
        static var previews: some View {
            FollowersCell(isFollowingCell: false)
               
        }
    }
}
