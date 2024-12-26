import Fluent
import Vapor

struct UserController: RouteCollection {
    func boot(routes: RoutesBuilder) throws {
        let userRoutes = routes.grouped("user")
        userRoutes.post("register", use: register)
        userRoutes.post("login", use: login)
        userRoutes.get(":id", use: profile)
    }

    func register(req: Request) throws -> EventLoopFuture<User> {
        let user = try req.content.decode(User.self)
        return user.save(on: req.db).map { user }
    }

    func login(req: Request) throws -> EventLoopFuture<String> {
        let loginRequest = try req.content.decode(User.self)
        return User.query(on: req.db)
            .filter(\.$email == loginRequest.email)
            .first()
            .unwrap(or: Abort(.unauthorized))
            .flatMapThrowing { user in
                guard user.password == loginRequest.password else {
                    throw Abort(.unauthorized)
                }
                return "Login successful"
            }
    }

    func profile(req: Request) throws -> EventLoopFuture<User> {
        guard let userID = req.parameters.get("id", as: UUID.self) else {
            throw Abort(.badRequest)
        }
        return User.find(userID, on: req.db)
            .unwrap(or: Abort(.notFound))
    }
}
