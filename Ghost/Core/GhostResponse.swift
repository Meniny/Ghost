//
//  GhostResponse.swift
//  Ghost
//
//  Created by Elias Abel on 22/3/17.
//
//

import Foundation

public struct GhostResponse {

    public let url: URL?

    public let mimeType: String?

    public let contentLength: Int64?

    public let textEncoding: String?

    public let filename: String?

    public let statusCode: Int?

    public let headers: [AnyHashable : Any]?

    public let localizedDescription: String?

    public let userInfo: [AnyHashable : Any]?

    public weak var ghostTask: GhostTask?

    public let responseObject: Any?

}

extension GhostResponse {

    public init(_ url: URL? = nil, mimeType: String? = nil, contentLength: Int64 = -1, textEncoding: String? = nil, filename: String? = nil, statusCode: Int? = nil, headers: [AnyHashable : Any]? = nil, localizedDescription: String? = nil, userInfo: [AnyHashable : Any]? = nil, ghostTask: GhostTask?, responseObject: Any? = nil) {
        self.url = url
        self.mimeType = mimeType
        self.contentLength = contentLength != -1 ? contentLength : nil
        self.textEncoding = textEncoding
        self.filename = filename
        self.statusCode = statusCode
        self.headers = headers
        self.localizedDescription = localizedDescription
        self.userInfo = userInfo
        self.ghostTask = ghostTask
        self.responseObject = responseObject
    }

}

extension GhostResponse {
    
    public func data() throws -> Data {
        do {
            return try GhostTransformer.object(object: responseObject)
        } catch {
            throw handle(error)
        }
    }

    public func object<T>() throws -> T {
        do {
            return try GhostTransformer.object(object: responseObject)
        } catch {
            throw handle(error)
        }
    }

    public func decode<D: Decodable>() throws -> D {
        do {
            return try GhostTransformer.decode(object: responseObject)
        } catch {
            throw handle(error)
        }
    }

    private func handle(_ error: Error) -> Error {
        switch error as! GhostError {
        case .parse(let transformCode, let message, let object, let underlying):
            return GhostError.parse(code: transformCode ?? statusCode, message: message, object: object ?? responseObject, underlying: underlying)
        default:
            return error
        }
    }

}

extension GhostResponse: Equatable {

    public static func ==(lhs: GhostResponse, rhs: GhostResponse) -> Bool {
        guard lhs.url != nil && rhs.url != nil else {
            return false
        }
        return lhs.url == rhs.url
    }

}

extension GhostResponse: CustomStringConvertible {

    public var description: String {
        var description = ""
        if let statusCode = statusCode?.description {
            description = description + statusCode
        }
        if let url = url?.description {
            if description.count > 0 {
                description = description + " "
            }
            description = description + url
        }
        if let localizedDescription = localizedDescription?.description {
            if description.count > 0 {
                description = description + " "
            }
            description = description + "(\(localizedDescription))"
        }
        return description
    }

}

extension GhostResponse: CustomDebugStringConvertible {

    public var debugDescription: String {
        return description
    }
    
}
