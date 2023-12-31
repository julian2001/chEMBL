//
//  NetworkError.swift
//  
//
//  Created by Julian Reyes on 12/31/23.
//

import Foundation

enum NetworkError: Error {
    case invalidURL
    case noData
    case httpError(Int)
    case decodingError(Error)
    case unknownError
}
