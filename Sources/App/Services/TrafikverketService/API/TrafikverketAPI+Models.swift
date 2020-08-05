//
//  TrafikverketAPI+Models.swift
//  
//
//  Created by Charlie Tuna on 2020-08-05.
//

import Foundation
import Vapor

extension TrafikverketAPI {
    struct RequestModel: Codable {
        let bookingSession: BookingSession
        let occasionBundleQuery: OccasionBundleQuery
    }

    struct BookingSession: Codable {
        let bookingModeId: Int = 0
        let excludeExaminationCategories: [Int] = []
        let ignoreBookingHindrance: Bool = false
        let ignoreDebt: Bool = false
        let licenceId: Int = 5
        let paymentIsActive: Bool = false
        let paymentReference: String? = nil
        let paymentUrl: String? = nil
        let rescheduleTypeId: Int = 0
        let socialSecurityNumber: String
    }
    struct OccasionBundleQuery: Codable {
        let examinationTypeId: Int = 3
        let languageId: Int = 4
        let locationId: Int
        let occasionChoiceId: Int = 1
        let startDate: String // Format -> "2020-07-31T22:00:00.000Z"
        let tachographTypeId: Int = 1
    }

    struct ResponseModel: Codable {
        let status: Int
        let url: String
        let data: [SingleData]
    }

    struct SingleData: Codable {
        let cost: String?
        let occasions: [Occasion]
    }

    struct Occasion: Codable, Content {
        let cost: String
        let costText: String
        let date: Date
        let duration: Duration
        let examinationCategory: Int
        let examinationId: Int?
        let examinationTypeId: Int
        let increasedFee: Bool
        let isEducatorBooking: Bool?
        let isLateCancellation: Bool
        let isOutsideValidDuration: Bool
        let languageId: Int
        let locationId: Int
        let locationName: String
        let name: String
        let occasionChoiceId: Int
        let placeAddress: String?
        let properties: String?
        let tachographTypeId: Int
        let time: String
        let vehicleTypeId: Int
    }

    struct Duration: Codable {
        let end: String
        let start: String
    }
}
