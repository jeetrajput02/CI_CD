//
//  ReportReasonModel.swift
//  WhosNext
//
//  Created by differenz240 on 02/12/22.
//

import Foundation

struct ReportReasonModel: Codable, Hashable, Equatable {
    var success: Bool?
    var statusCode: Int?
    var message: String?
    var data: [ReportReasonData]?
    
    enum CodingKeys: String, CodingKey {
        case success
        case statusCode = "status_code"
        case message, data
    }
}

struct ReportReasonData: Codable, Hashable, Equatable {
    var reasonID: Int?
    var reportReason: String?
    
    enum CodingKeys: String, CodingKey {
        case reasonID = "reason_id"
        case reportReason = "report_reason"
    }
}

// MARK: - API Calls
extension ReportReasonModel {
    /// `api call` for get report reason
    static func getReportReasons(success: @escaping (ReportReasonModel?, String) -> Void, failure: @escaping (String) -> Void) -> Void {
        Indicator.show()
        
        APIManager.makeRequest(with: Constant.ServerAPI.kGetReportReason, method: .get, parameter: nil, success: { response -> Void in
            guard let json = response as? [String: Any] else { return }
            guard let data = try? JSONSerialization.data(withJSONObject: json) else { return }
            
            do {
                let reportReasonModel = try JSONDecoder().decode(ReportReasonModel.self, from: data)
                
                success(reportReasonModel, reportReasonModel.message ?? "")
                
                Indicator.hide()
            } catch let error {
                print(error.localizedDescription)
            }
        }, failure: { error, errorCode, isAuth -> Void  in
            Indicator.hide()
            failure(error)
        }, connectionFailed: { error -> Void in
            Indicator.hide()
            
            failure(error)
        })
    }
}
