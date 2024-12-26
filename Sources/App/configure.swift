import NIOSSL
import Fluent
import FluentSQLiteDriver
import Vapor

// configures your application
public func configure(_ app: Application) async throws {
    // uncomment to serve files from /Public folder
    // app.middleware.use(FileMiddleware(publicDirectory: app.directory.publicDirectory))
    app.logger.logLevel = .debug
    app.databases.use(.sqlite(.init(storage: .memory)), as: .sqlite)
    app.migrations.add(CreateUser())
    
    try await app.autoMigrate().get()

    // register routes
    try routes(app)
}
