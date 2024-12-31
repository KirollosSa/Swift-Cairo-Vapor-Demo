//
//  APIUser.swift
//  DemoTest
//
//  Created by Kirollos Saweres on 31/12/2024.
//
import Vapor

struct APIUser: Content {
    var id: UUID?
    var email: String
}
