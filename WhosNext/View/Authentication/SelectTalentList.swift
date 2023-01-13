//
//  SelectTalentList.swift
//  WhosNext
//
//  Created by differenz195 on 28/09/22.
//

import SwiftUI

struct SelectTalentList: View {
    // MARK: - Variables
    @Environment(\.presentationMode) private var presentationMode: Binding<PresentationMode>
    @EnvironmentObject private var registerVM: RegisterViewModel
    
    @State private var searchText: String = ""
    @State private var showingAlert = false
    
    @Binding var categoryListModel: [SelectTalentModel]
    @Binding var selectedCategories: [SelectTalentModel]
    
    var isFromRegister: Bool

    var body: some View {
        GeometryReader { geoReader in
            VStack {
                self.searchTextfield
                self.categoryList
                self.buttonStack
                    .padding(.bottom, geoReader.size.height < 640.0 ? 24.0 : 0.0)
            }
        }
    }
    
    /// `search` textfield
    private var searchTextfield: some View {
        ZStack {
            Color.myDarkCustomColor.frame(height: 80.0)
            
            HStack {
                Spacer().frame(width: 8.0)
                
                HStack (alignment: .center, spacing: 10.0) {
                    Image(systemName: "magnifyingglass")
                        .resizable()
                        .frame(width: 20.0, height: 20.0, alignment: .center)
                        .foregroundColor(Color.myDarkCustomColor)
                    
                    TextField("add your talent or business please", text: self.$searchText)
                        .onChange(of: self.searchText, perform: { searchText in
                            if searchText.last == " " {
                                self.searchText.removeLast()
                            }
                        })
                    
                    /* let categoryArr = self.categoryListModel.filter({
                        $0.category.hasPrefix(self.searchText) || self.searchText == ""
                    })
                    
                    if self.searchText.count > 0 && categoryArr.count == 0 &&  self.searchText.trimWhiteSpace != "" {
                        Button(action: {
                            let dict = [
                                selectTalentModelKey.categoryId: -1,
                                selectTalentModelKey.category: self.searchText
                            ] as [String: Any]
                            
                            let category = SelectTalentModel(Dict: dict)
                            
                            if self.isFromRegister {
                                if self.selectedCategories.count != 3 {
                                    self.categoryListModel.append(category)
                                    self.selectedCategories.append(category)
                                } else {
                                    self.showingAlert = true
                                }
                            } else {
                                self.categoryListModel.append(category)
                                self.selectedCategories.append(category)
                            }
                            self.searchText = ""
                        }, label: { Text("Add").foregroundColor(.black) })
                    } */
                }
                .font(.body)
                .padding([.top, .bottom], 4.0)
                .padding(EdgeInsets(top: 8.0, leading: 8.0, bottom: 8.0, trailing: 8.0))
                .overlay(RoundedRectangle(cornerRadius: 10.0).stroke(.black.opacity(0.7), lineWidth: 2))
                .background(Color.myCustomColor, alignment: .center)
                .cornerRadius(10.0)
                
                Spacer().frame(width: 8.0)
            }
        }
    }
    
    /// `category` list
    private var categoryList: some View {
        ScrollView(showsIndicators: false) {
            LazyVStack(alignment: .leading) {
                let categoryArr = self.categoryListModel.filter({ $0.category.hasPrefix(self.searchText) || self.searchText == "" })
                
                ForEach(categoryArr, id: \.self) { category in
                    HStack {
                        Image(self.selectedCategories.contains(where: { $0 == category })
                              ? IdentifiableKeys.ImageName.kCircleFill
                              : IdentifiableKeys.ImageName.kCircleBlank)
                        .resizable()
                        .frame(width: 20.0, height: 20.0, alignment: .center)
                        
                        Text(category.category)
                            .font(.custom(Constant.FontStyle.Regular.rawValue, size: Constant.FontSize._16FontSize))
                    }
                    .onTapGesture {
                        if self.selectedCategories.contains(where: { $0 == category }) {
                            self.selectedCategories.removeAll(where: { $0 == category })
                        } else {
                            if self.isFromRegister {
                                if self.selectedCategories.count != 3 {
                                    self.selectedCategories.append(category)
                                } else {
                                    self.showingAlert = true
                                }
                            } else {
                                self.selectedCategories.append(category)
                            }
                        }
                        
                        let selectedCategoryIds = self.selectedCategories.map({
                            $0.categoryId == -1 ? "\($0.category)" : "\($0.categoryId)"
                        })
                        
                        print("selected categories: \(selectedCategoryIds.joined(separator: ","))" )
                    }
                    
                    RoundedRectangle(cornerRadius: 0)
                        .frame(height: 1.5)
                        .foregroundColor(Color.CustomColor.AppSnippetsColor)
                }
            }
        }
        .padding()
        .alert(isPresented: self.$showingAlert) {
            Alert(
                title: Text(""),
                message: Text("Please Select your talent / business less than or equals to three."),
                dismissButton: .default(Text("Ok"))
            )
        }
    }
    
    /// `button` stack
    private var buttonStack: some View {
        HStack {
            CommonButton(title: IdentifiableKeys.Buttons.kDone,cornerradius: 0) {
                self.presentationMode.wrappedValue.dismiss()
            }
            
            CommonButton(title: IdentifiableKeys.Buttons.kCancel,cornerradius: 0) {
                self.presentationMode.wrappedValue.dismiss()
                
                self.selectedCategories.removeAll()
            }
        }
        .padding(EdgeInsets(top: 0.0, leading: 16.0, bottom: 16.0, trailing: 16.0))
        .frame(height: 10.0)
    }
}

// MARK: - Previews
struct SelectTalentList_Previews: PreviewProvider {
    static var previews: some View {
        SelectTalentList(categoryListModel: .constant([]), selectedCategories: .constant([]), isFromRegister: true)
    }
}

