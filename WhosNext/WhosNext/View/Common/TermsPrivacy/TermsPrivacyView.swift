//
//  TermsPrivacyView.swift
//  WhosNext
//
//  Created by differenz148 on 29/09/22.
//

import SwiftUI

struct TermsPrivacyView: View {
    
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    var isForPrivacy : Bool = true
    let privacyPolicyUrl = Bundle.main.url(forResource: "privacypolicy", withExtension:"html")
    let termsConditionsUrl = Bundle.main.url(forResource: "terms_conditions", withExtension:"html")
    
    var body: some View {
        VStack(alignment: .leading) {
            let request = URLRequest(url: isForPrivacy ? (privacyPolicyUrl ?? URL(fileURLWithPath: "")) : (termsConditionsUrl ?? URL(fileURLWithPath: "")))
            WebView(request: request)
        }
        
        .navigationBarBackButtonHidden(true)
        .navigationBarItems(leading:
                                HStack {
            
            Button {
                self.presentationMode.wrappedValue.dismiss()
            } label: {
                Image(IdentifiableKeys.ImageName.kBackArrowBlack)
            }
            
            Text(isForPrivacy ? IdentifiableKeys.NavigationbarTitles.kPrivacypolicy :  IdentifiableKeys.NavigationbarTitles.kTermsandCondition)
                .font(.custom(Constant.FontStyle.Regular.rawValue, size: Constant.FontSize._28FontSize))
            
        })
        .navigationBarColor(backgroundColor: UIColor(Color("uniColor")))
    }
}

struct TermsPrivacyView_Previews: PreviewProvider {
    static var previews: some View {
        TermsPrivacyView()
    }
}
