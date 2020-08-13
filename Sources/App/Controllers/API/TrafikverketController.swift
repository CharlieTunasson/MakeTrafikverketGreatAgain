//
//  File.swift
//  
//
//  Created by Charlie Tuna on 2020-08-05.
//

import Vapor

fileprivate let service = TrafikverketService()

final class TrafikverketController: RouteCollection {
    func boot(routes: RoutesBuilder) throws {
        routes.post("tests", use: getOccasions)
        routes.get("tests", "healthCheck", use: healthCheck)
    }
}

extension TrafikverketController {
    func getOccasions(_ req: Request) throws -> EventLoopFuture<[TrafikverketAPI.Occasion]> {
        let body = try req.content.decode(TrafikverketAPI.Body.self)
        let promise = req.eventLoop.makePromise(of: [TrafikverketAPI.Occasion].self)
        service.getAllOccasions(for: body) { result in
                        switch result {
            case .success(let occasions):
                promise.succeed(occasions)
            case .failure:
                promise.succeed([])
            }
        }
        return promise.futureResult
    }

    func healthCheck(_ req: Request) throws -> String {
        return "OK"
    }
}
