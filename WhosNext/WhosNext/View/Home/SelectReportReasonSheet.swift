//
//  SelectReportReasonSheet.swift
//  WhosNext
//
//  Created by differenz240 on 02/12/22.
//

import SwiftUI

struct SelectReportReasonSheet: View {
    @Binding var reportReasonsModel: ReportReasonModel?
    @Binding var selectedReportReason: ReportReasonData?
    
    var doneAction: () -> Void
    var cancelAction: () -> Void

    var body: some View {
        GeometryReader { geoReader in
            VStack(alignment: .center) {
                Text("Select a reason to report")
                    .font(.custom(Constant.FontStyle.Bold.rawValue, size: Constant.FontSize._18FontSize))
                    .padding(.top, 12.0)

                self.reportReasonList
                self.buttonStack
                    .padding(.bottom, geoReader.size.height < 640.0 ? 18.0 : 0.0)
            }
        }
    }
    
    /// `report reason` list
    private var reportReasonList: some View {
        ScrollView(showsIndicators: false) {
            VStack(alignment: .leading) {
                if let reportReasonsArr = self.reportReasonsModel?.data {
                    ForEach(reportReasonsArr, id: \.self) { reason in
                        HStack {
                            Image(self.selectedReportReason == reason ? IdentifiableKeys.ImageName.kCircleFill : IdentifiableKeys.ImageName.kCircleBlank)
                                .resizable()
                                .frame(width: 20, height: 20, alignment: .center)

                            Spacer().frame(width: 8.0)

                            Text(reason.reportReason ?? "")
                                .font(.custom(Constant.FontStyle.Regular.rawValue, size: Constant.FontSize._16FontSize))
                        }
                        .frame(height: 30.0)
                        .onTapGesture {
                            self.selectedReportReason = reason
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
            // CommonButton(title: IdentifiableKeys.Buttons.kDone, action: self.doneAction)

            CommonButton(title: IdentifiableKeys.Buttons.kDone, cornerradius: 0) {
                self.doneAction()
            }
            
            CommonButton(title: IdentifiableKeys.Buttons.kCancel, cornerradius: 0) {
                self.cancelAction()
            }
        }
        .padding(EdgeInsets(top: 0.0, leading: 16.0, bottom: 16.0, trailing: 16.0))
        .frame(height: 10)
    }
}

// MARK: - Previews
struct SelectReportReasonSheet_Previews: PreviewProvider {
    static var previews: some View {
        SelectReportReasonSheet(reportReasonsModel: .constant(nil), selectedReportReason: .constant(nil), doneAction: {}, cancelAction: {})
    }
}
