import Vapor

//fileprivate var service = TrafikverketService(for: true)

fileprivate var service = TrafikverketService(for: [.stockholmCity, .karlskrona])

func routes(_ app: Application) throws {
    try app.register(collection: TrafikverketController())
}
