//
//  File.swift
//  
//
//  Created by Charlie Tuna on 2020-08-05.
//

import Vapor

fileprivate let service = TrafikverketService(for: [.karlskrona])

final class TrafikverketController: RouteCollection {
    func boot(routes: RoutesBuilder) throws {
        routes.get("tests", ":ssn", use: getOccasions)
        routes.get("tests", use: get)
    }
}

extension TrafikverketController {
    func getOccasions(_ req: Request) throws -> EventLoopFuture<[TrafikverketAPI.Occasion]> {
        let ssn = req.parameters.get("ssn")!
        let promise = req.eventLoop.makePromise(of: [TrafikverketAPI.Occasion].self)
        service.getAllOccasions(for: ssn, dateThreshold: .fortyFiveDays, language: .engelska) { result in
            switch result {
            case .success(let occasions):
                promise.succeed(occasions)
            case .failure:
                promise.succeed([])
            }
        }
        return promise.futureResult
    }

    func get(_ req: Request) throws -> String {
        return "test"
    }
}
