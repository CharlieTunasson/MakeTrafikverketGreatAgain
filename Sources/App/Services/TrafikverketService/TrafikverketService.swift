//
//  File.swift
//  
//
//  Created by Charlie Tuna on 2020-08-02.
//

import Foundation

final class TrafikverketService {

    // MARK: - Properties

    private let dateFormatter: DateFormatter = {
         let dateFormatter = DateFormatter()
         dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSS'Z'"
         return dateFormatter
     }()

    var api: TrafikverketAPI!    

    private var dateStringNow: String {
        dateFormatter.string(from: Date())
    }

    var locations: [Location] = []

    // MARK: - Init

    init(for locations: [Location]) {
        self.locations = locations
    }

    // MARK: - Public operations

    func getAllOccasions(for ssn: String,
                         dateThreshold: TrafikverketAPI.DateThreshold,
                         language: Language,
                         completion: @escaping (Result<[TrafikverketAPI.Occasion], Error>) -> Void) {
        api = TrafikverketAPI(dateThreshold: dateThreshold)
        api.getAllOccasions(ssn: ssn,
                            languageId: language.rawValue,
                            locationIds: locations.map({ $0.rawValue }),
                            startDateString: dateStringNow) { result in
                                completion(result)
        }
    }    
}

// MARK: - Locations

extension TrafikverketService {
    enum Location: Int {
        case orebro = 1000001
        case karlskoga = 1000003
        case eskilstuna = 1000005
        case linköping = 1000009
        case motala = 1000011
        case vimmerby = 1000015
        case umea = 1000021
        case farsta = 1000019
        case ljungby = 1000028
        case vaxjo = 1000030
        case sunne = 1000036
        case vasteras = 1000038
        case fagersta = 1000039
        case koping = 1000040
        case kristianstad = 1000046
        case karlskrona = 1000047
        case karlshamn = 1000048
        case hudiksvall = 1000056
        case harnosand = 1000057
        case malmo = 1000061
        case lund = 1000062
        case uppsala = 1000071
        case jonkoping = 1000074
        case vetlanda = 1000078
        case lulea = 1000082
        case haparanda = 1000084
        case kalix = 1000085
        case pitea = 1000087
        case alvsbyn = 1000088
        case overtornea = 1000089
        case gallivare = 1000090
        case jokkmokk = 1000091
        case kalmar = 1000093
        case oskarshamn = 1000094
        case vastervik = 1000095
        case visby = 1000097
        case falun = 1000098
        case sundsvall = 1000105
        case ornskoldsvik = 1000106
        case skelleftea = 1000111
        case ostersund = 1000112
        case gavle = 1000118
        case sveg = 1000117
        case bollnas = 1000121
        case angelholm = 1000122
        case skovde = 1000130
        case sodertalje = 1000132
        case sollentuna = 1000134
        case stockholmCity = 1000140
        case nykoping = 1000149
        case borlange = 1000324
        case jarfalla = 1000326
        case norrkoping = 1000329
    }

    enum Language: Int {
        case albanska  = 1
        case arabiska = 2
        case engelska = 4
        case finska = 5
        case franska = 6
        case persiska = 7
        case ryska = 8
        case sorani = 9
        case spanska = 10
        case turkiska = 11
        case tyska = 12
        case svenska = 13
        case bosniska = 14
        case kroatiska = 15
        case serbiska = 16
        case somaliska = 128
        case thailändska = 133
    }
}
