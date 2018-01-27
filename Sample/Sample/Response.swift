//
//  Response.swift
//  Sample
//
//  Created by Alejandro Ruperez Hernando on 23/8/17.
//

import Foundation

public protocol PortfolioItemType: Codable {
    var title: String { get set }
    var detail: String { get set }
    var image: String { get set }
    var url: String { get set }
    var available: Bool { get set }
    var desc: String? { get set }
}

// --------

struct ProtfolioResponse: Codable {
    let portfolio: Portfolio
}

struct Portfolio: Codable {
    var type: String
    var data: [PortfolioItem]
}

struct PortfolioItem: Codable {
    var title: String
    var detail: String
    var image: String
    var url: String
    var available: Bool
    var desc: String?
    
    enum Keys: String, CodingKey {
        case desc = "description"
    }
}

// ---------

struct AboutResponse: Codable {
    let about: [String]
}
