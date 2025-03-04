//
//  User.swift
//  DemoTest
//
//  Created by Kirollos Saweres on 23/12/2024.
//
import Fluent
import Vapor

final class User: Model, Content {
    static let schema = "users" // Table name
    
    @ID(key: .id)
    var id: UUID?

    @Field(key: "email")
    var email: String

    @Field(key: "password")
    var password: String

    init() { }

    init(id: UUID? = nil, email: String, password: String) {
        self.id = id
        self.email = email
        self.password = password
    }
}
