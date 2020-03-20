//
//  AuthBody.swift
//  OnTheMap
//
//  Created by Agnidhra Gangopadhyay on 3/3/20.
//  Copyright © 2020 Agnidhra Gangopadhyay. All rights reserved.
//

import Foundation

// MARK: - Empty
struct AuthBody: Codable {
    let udacity: Udacity
}

// MARK: - Udacity
struct Udacity: Codable {
    let username, password: String
}

// MARK: - PostLocation
struct PostLocation: Codable {
    let uniqueKey, firstName, lastName, mapString: String
    let mediaURL: String
    let latitude, longitude: Double
}
