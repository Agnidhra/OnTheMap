//
//  AuthResponse.swift
//  OnTheMap
//
//  Created by Agnidhra Gangopadhyay on 3/3/20.
//  Copyright © 2020 Agnidhra Gangopadhyay. All rights reserved.
//

import Foundation


    // MARK: - AuthResponse
    struct AuthSuccess: Decodable {
        let account: Account
        let session: Session
    }
    
    // MARK: - Account
    struct Account: Decodable {
        let registered: Bool
        let key: String
    }
    
    // MARK: - Session
    struct Session: Decodable {
        let id, expiration: String
    }
    
    //MARK: AuthFailure
    struct FailureType: Decodable {
        let status: Int
        let error: String
    }

    // MARK: - StudentLocationDetails
    struct StudentLocationDetails: Decodable {
        var results: [Result]
    }

    // MARK: - Result
    struct Result: Decodable {
        let firstName, lastName: String
        let longitude, latitude: Double
        let mapString: String
        let mediaURL: String
        let uniqueKey, objectID, createdAt, updatedAt: String
        
        enum CodingKeys: String, CodingKey {
            case firstName, lastName, longitude, latitude, mapString, mediaURL, uniqueKey
            case objectID = "objectId"
            case createdAt, updatedAt
        }
    }

    // MARK: - PostSuccessResponse
    struct PostSuccessResponse: Codable {
        let objectID, createdAt: String
        
        enum CodingKeys: String, CodingKey {
            case objectID = "objectId"
            case createdAt
        }
    }

    


