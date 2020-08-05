//
//  File.swift
//  
//
//  Created by Charlie Tuna on 2020-08-05.
//

import Foundation

final class TrafikverketAPI {

    enum DateThreshold: Int {
        case twoMonths = 60
        case fortyFiveDays = 45
        case month = 30
        case fifteenDays = 15
        case week = 7
    }

    enum TrafikverketAPIError: Error {
        case noData
    }

    // MARK: - Properties

    private let decodeDateFormatter: DateFormatter = {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        return dateFormatter
    }()

    private let path = "https://fp.trafikverket.se/Boka/occasion-bundles"
    private let defaultHeaders = ["Content-Type":"application/json"]
//    private let idsToExclude = [1000016, 1000128, 1000147, 1000148] // Returns 500

    // Initiative
    private let dateThreshold: DateThreshold
    private var thresholdDate: Date {
        Date().addDay(n: dateThreshold.rawValue)
    }

    // Operational
    private var counter: Int = 0
    private var allOccasions: [TrafikverketAPI.Occasion] = []

    // MARK: - Init

    init(dateThreshold: DateThreshold) {
        self.dateThreshold = dateThreshold
    }

    // MARK: - Public operations

    func getAllOccasions(ssn: String,
                         locationIds: [Int],
                         startDateString: String,
                         completion: @escaping (Result<[Occasion], Error>) -> Void) {

        locationIds.forEach { locationId in
            getOccasionsForLocation(ssn: ssn, locationId: locationId, startDateString: startDateString) { [weak self] result in
                guard let self = self else { return }
                self.counter = self.counter + 1
                switch result {
                case .success(let occasions):
                    occasions.forEach { (occasion) in
                        if occasion.date < self.thresholdDate {
                            self.allOccasions.append(occasion)
                        }
                    }
                case .failure(_):
                    break
                }

                if self.counter == locationIds.count {
                    self.allOccasions.sort(by: { $0.date < $1.date })
                    completion(.success(self.allOccasions))
                    self.allOccasions = []
                    self.counter = 0
                }
            }
        }
    }

    // MARK: - Private operations

    private func getOccasionsForLocation(ssn: String,
                                         locationId: Int,
                                         startDateString: String,
                                         completion: @escaping (Result<[Occasion], Error>) -> Void) {
        do {
            try fetch(with: RequestModel(bookingSession: BookingSession(socialSecurityNumber: ssn),
                                         occasionBundleQuery: OccasionBundleQuery(locationId: locationId, startDate: startDateString))) { result in
                                            completion(result)
            }
        } catch {
            completion(.failure(error))
        }
    }

    private func fetch(with body: RequestModel, completion: @escaping (Result<[Occasion], Error>) -> Void) throws {
        guard let url = URL(string: path) else {
            return
        }

        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = "POST"
        let bodyData = try JSONEncoder().encode(body)
        urlRequest.httpBody = bodyData
        urlRequest.timeoutInterval = 500
        urlRequest.allHTTPHeaderFields = defaultHeaders

        URLSession.shared.dataTask(with: urlRequest) { [weak self]
            (data, response, error) in

            guard let self = self else { return }

            if let error = error {
                print(error)
                completion(.failure(error))
                return
            }
            guard let _data = data else {
                print("No data")
                completion(.failure(TrafikverketAPIError.noData))
                return
            }
            if let httpResponse = response as? HTTPURLResponse {
                switch httpResponse.statusCode {
                case 200...299:
                    let occasions = self.decodedOccasions(data: _data)
                    completion(.success(occasions))
                case 400...499:
                    completion(.failure(TrafikverketAPIError.noData))
                    return
                case 500...599:
                    print("-> ### \(body.occasionBundleQuery.locationId) ###")
                    completion(.failure(TrafikverketAPIError.noData))
                    return
                default:
                    completion(.failure(TrafikverketAPIError.noData))
                    return
                }
            } else {
                completion(.failure(TrafikverketAPIError.noData))
            }
        }.resume()
    }

    private func decodedOccasions(data: Data) -> [Occasion] {
        var occasions: [Occasion] = []
        do {
            let decoder = JSONDecoder()
            decoder.dateDecodingStrategy = .formatted(decodeDateFormatter)
            let response = try decoder.decode(ResponseModel.self, from: data)
            response.data.forEach { singleData in
                singleData.occasions.forEach { occasion in
                    occasions.append(occasion)
                }
            }
            return occasions
        } catch {
            return []
        }
    }
}
