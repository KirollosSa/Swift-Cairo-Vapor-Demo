//
//  UserController.swift
//  DemoTest
//
//  Created by Kirollos Saweres on 23/12/2024.
//

import Fluent
import Vapor

/// `UserController` is responsible for managing user-related routes and their respective handlers.
struct UserController: RouteCollection {
    
    /// Registers the user-related routes within the application's routing system.
    ///
    /// - Parameter routes: The main `RoutesBuilder` instance to register routes to.
    /// - Throws: An error if the registration fails.
    func boot(routes: RoutesBuilder) throws {
        let userRoutes = routes.grouped("user") // Creates a route group with the base path "/user".
        userRoutes.post("register", use: register) // POST /user/register: Handles user registration.
        userRoutes.post("login", use: login) // POST /user/login: Handles user login.
        userRoutes.get(use: getProfile) // GET /user/:id: Retrieves a user's profile by ID.
        userRoutes.get("all", use: getAllUsers) // GET /user/all: Fetches all users.
    }

    /// Handles the user registration process.
    ///
    /// - Parameter req: The incoming request containing the user's registration data.
    /// - Returns: The newly created `User` instance.
    /// - Throws: An error if decoding or saving the user fails.
    @Sendable func register(req: Request) async throws -> User {
        let user = try req.content.decode(User.self) // Decodes the request body into a `User` model.
        try await user.save(on: req.db) // Saves the user to the database.
        return user // Returns the saved user.
    }
    
    /// Handles the user login process.
    ///
    /// - Parameter req: The incoming request containing the user's login credentials.
    /// - Returns: The authenticated `User` instance.
    /// - Throws: An error if decoding fails or if credentials are invalid.
    @Sendable func login(req: Request) async throws -> User {
        let loginData = try req.content.decode(User.self) // Decodes the login data from the request body.
        guard let existingUser = try await User.query(on: req.db)
            .filter(\.$email == loginData.email) // Finds a user with the matching email.
            .first(),
              existingUser.password == loginData.password else { // Checks if the passwords match.
            throw Abort(.unauthorized, reason: "Invalid credentials") // Throws an error if credentials are invalid.
        }
        return existingUser // Returns the authenticated user.
    }
    
    /// Retrieves a user's profile by their unique ID.
    ///
    /// - Parameter req: The incoming request containing the user ID as a parameter.
    /// - Returns: The `User` instance corresponding to the provided ID.
    /// - Throws: An error if the ID is missing, invalid, or if the user is not found.
    @Sendable func getProfile(req: Request) async throws -> APIUser {
        // Validate and extract the user ID from the request parameters.
        guard let userIDString = req.query[String.self, at: "id"],
              let userID = UUID(uuidString: userIDString) else {
            throw Abort(.badRequest, reason: "Invalid or missing user ID")
        }

        // Retrieve the user from the database or throw a not found error.
        guard let user = try await User.find(userID, on: req.db) else {
            throw Abort(.notFound, reason: "User not found")
        }

        // Map the User model to an APIUser and return it.
        return APIUser(id: user.id, email: user.email)
    }
    
    /// Fetches a list of all registered users.
    ///
    /// - Parameter req: The incoming request.
    /// - Returns: An array of all `User` instances.
    /// - Throws: An error if querying the database fails.
    @Sendable func getAllUsers(req: Request) async throws -> [User] {
        return try await User.query(on: req.db).all() // Queries the database to fetch all users.
    }
}
