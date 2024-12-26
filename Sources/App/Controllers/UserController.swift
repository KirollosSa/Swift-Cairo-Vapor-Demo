//
//  UserController.swift
//  DemoTest
//
//  Created by Kirollos Saweres on 23/12/2024.
//


import Fluent
import Vapor

struct UserController: RouteCollection {
    func boot(routes: RoutesBuilder) throws {
        let userRoutes = routes.grouped("user")
        userRoutes.post("register", use: register)
        userRoutes.post("login", use: login)
        userRoutes.get(":id", use: getProfile)
        userRoutes.get("all", use: getAllUsers)
    }

    @Sendable func register(req: Request) throws -> EventLoopFuture<User> {
        let user = try req.content.decode(User.self)
        return user.save(on: req.db).map { user }
    }
    
    @Sendable func login(req: Request) async throws -> User {
        let loginData = try req.content.decode(User.self)
        guard let existingUser = try await User.query(on: req.db)
            .filter(\.$email == loginData.email)
            .first(),
              existingUser.password == loginData.password else {
            throw Abort(.unauthorized, reason: "Invalid credentials")
        }
        return existingUser
    }
    
    @Sendable func getProfile(req: Request) async throws -> User {
            guard let userID = req.parameters.get("userID", as: UUID.self) else {
                throw Abort(.badRequest, reason: "Missing or invalid user ID")
            }
            guard let user = try await User.find(userID, on: req.db) else {
                throw Abort(.notFound, reason: "User not found")
            }
            return user
        }
    
    @Sendable func getAllUsers(req: Request) throws -> EventLoopFuture<[User]> {
        return User.query(on: req.db).all()
    }
}
