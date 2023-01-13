//
//  SelectCitySheet.swift
//  WhosNext
//
//  Created by differenz240 on 09/11/22.
//

import SwiftUI

struct SelectCitySheet: View {
    @Environment(\.presentationMode) private var presentationMode: Binding<PresentationMode>
    
    @State private var searchText = ""
    
    @Binding var cityModel: CityModel?
    @Binding var selectedCity: CityData?

    var body: some View {
        GeometryReader { geoReader in
            VStack {
                self.searchTextfield
                self.cityList
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
                    
                    TextField("Search city here", text: self.$searchText)
                        .onChange(of: self.searchText, perform: { searchText in
                            if searchText.last == " " {
                                self.searchText.removeLast()
                            }
                        })
                    
                    /* if let cityArr = self.cityModel?.data.filter({ $0.city.hasPrefix(self.searchText) || self.searchText == "" }) {
                        if self.searchText.count > 0 && cityArr.count == 0  && self.searchText.trimWhiteSpace != "" {
                            Button(action: {
                                let city = CityData(cityID: -1, city: self.searchText)
                                
                                self.cityModel?.data.append(city)
                                self.selectedCity = city
                                
                                self.searchText = ""
                            }, label: { Text("Add").foregroundColor(.black) })
                        }
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
    
    /// `city` list
    private var cityList: some View {
        ScrollView(showsIndicators: false) {
            LazyVStack(alignment: .leading) {
                if let cityArr = self.cityModel?.data.filter({ $0.city.hasPrefix(self.searchText) || self.searchText == "" }) {
                    ForEach(cityArr, id: \.self) { city in
                        HStack {
                            Image(self.selectedCity == city ? IdentifiableKeys.ImageName.kCircleFill : IdentifiableKeys.ImageName.kCircleBlank)
                                .resizable()
                                .frame(width: 20, height: 20, alignment: .center)

                            Spacer().frame(width: 8.0)

                            Text(city.city)
                                .font(.custom(Constant.FontStyle.Regular.rawValue, size: Constant.FontSize._16FontSize))
                        }
                        .frame(height: 30.0)
                        .onTapGesture {
                            self.selectedCity = city
                        }
                        
                        RoundedRectangle(cornerRadius: 0)
                            .frame(height: 1.5)
                            .foregroundColor(Color.appSnippetsColor)
                    }
                }
            }
        }
        .padding()
    }
    
    /// `button` stack
    private var buttonStack: some View {
        HStack {
            CommonButton(title: IdentifiableKeys.Buttons.kDone,cornerradius: 0) {
                self.presentationMode.wrappedValue.dismiss()
            }
            
            CommonButton(title: IdentifiableKeys.Buttons.kCancel,cornerradius: 0) {
                self.presentationMode.wrappedValue.dismiss()
                
                self.selectedCity = nil
            }
        }
        .padding(EdgeInsets(top: 0.0, leading: 16.0, bottom: 16.0, trailing: 16.0))
        .frame(height: 10)
    }
}

// MARK: - Previews
struct SelectCitySheet_Previews: PreviewProvider {
    static var previews: some View {
        SelectCitySheet(cityModel: .constant(nil), selectedCity: .constant(nil))
    }
}


