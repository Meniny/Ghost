//
//  GhostError.swift
//  Ghost
//
//  Created by Elias Abel on 22/3/17.
//
//

import Foundation

public enum GhostError: Error {
    case ghost(code: Int?, message: String, headers: [AnyHashable : Any]?, object: Any?, underlying: Error?)
    case parse(code: Int?, message: String, object: Any?, underlying: Error?)
    
    public var code: Int? {
        switch self {
        case .ghost(code: let c, message: _, headers: _, object: _, underlying: _):
            return c ?? _code
        case .parse(code: let c, message: _, object: _, underlying: _):
            return c ?? _code
        }
    }
    
    public var underlying: Error? {
        switch self {
        case .ghost(code: _, message: _, headers: _, object: _, underlying: let u):
            return u
        case .parse(code: _, message: _, object: _, underlying: let u):
            return u
        }
    }
    
    public var message: String? {
        switch self {
        case .ghost(code: _, message: let m, headers: _, object: _, underlying: _):
            return m ?? localizedDescription
        case .parse(code: _, message: let m, object: _, underlying: _):
            return m ?? localizedDescription
        }
    }
    
    public var headers: [AnyHashable : Any]? {
        switch self {
        case .ghost(code: _, message: _, headers: let h, object: _, underlying: _):
            return h
        default: return nil
        }
    }
}

extension GhostError {

    public func object<T>() throws -> T {
        switch self {
        case .ghost(let code, _, _, let object, let underlying):
            return try objectTransformation(code, object, underlying)
        case .parse(let code, _, let object, let underlying):
            return try objectTransformation(code, object, underlying)
        }
    }

    public func decode<D: Decodable>() throws -> D {
        switch self {
        case .ghost(let code, _, _, let object, let underlying):
            return try decodeTransformation(code, object, underlying)
        case .parse(let code, _, let object, let underlying):
            return try decodeTransformation(code, object, underlying)
        }
    }

    private func objectTransformation<T>(_ code: Int? = nil, _ object: Any? = nil, _ underlying: Error? = nil) throws -> T {
        do {
            return try GhostTransformer.object(object: object)
        } catch {
            throw handle(error, code, underlying)
        }
    }

    private func decodeTransformation<D: Decodable>(_ code: Int? = nil, _ object: Any? = nil, _ underlying: Error? = nil) throws -> D {
        do {
            return try GhostTransformer.decode(object: object)
        } catch {
            throw handle(error, code, underlying)
        }
    }

    private func handle(_ error: Error, _ code: Int? = nil, _ underlying: Error? = nil) -> Error {
        switch error as! GhostError {
        case .parse(let transformCode, let message, let object, let transformUnderlying):
            return GhostError.parse(code: transformCode ?? code, message: message, object: object, underlying: transformUnderlying ?? underlying)
        default:
            return error
        }
    }
    
}

extension GhostError {

    public var localizedDescription: String {
        switch self {
        case .ghost(_, let message, _, _, let underlying), .parse(_, let message, _, let underlying):
            if let localizedDescription = underlying?.localizedDescription, localizedDescription != message {
                return message + " " + localizedDescription
            }
            return message
        }
    }

}

extension GhostError: CustomStringConvertible {

    public var description: String {
        return localizedDescription
    }

}

extension GhostError: CustomDebugStringConvertible {

    public var debugDescription: String {
        switch self {
        case .ghost(let code, _, _, _, _), .parse(let code, _, _, _):
            if let code = code?.description {
                return code + " " + localizedDescription
            }
            return localizedDescription
        }
    }
    
}

extension GhostError: CustomNSError {

    public var errorCode: Int {
        switch self {
        case .ghost(let code, _, _, _, _):
            return code ?? 0
        case .parse(let code, _, _, _):
            return code ?? 1
        }
    }

    public var errorUserInfo: [String : Any] {
        switch self {
        case .ghost(_, let message, _, _, let underlying), .parse(_, let message, _, let underlying):
            guard let underlying = underlying else {
                return [NSLocalizedDescriptionKey: localizedDescription, NSLocalizedFailureReasonErrorKey: message]
            }
            return [NSLocalizedDescriptionKey: localizedDescription, NSLocalizedFailureReasonErrorKey: message, NSUnderlyingErrorKey: underlying]
        }
    }

}

public extension GhostError {
    public static func ghostError(from error: Error) -> GhostError {
        return GhostError.ghost(code: error._code,
                                message: error.localizedDescription,
                                headers: nil,
                                object: nil,
                                underlying: error)
    }
    
    public static func parseError(from error: Error) -> GhostError {
        return GhostError.parse(code: error._code,
                                message: error.localizedDescription,
                                object: nil,
                                underlying: error)
    }
    
    public static var unknown: GhostError {
        return GhostError.ghost(code: 0, message: "Unknown", headers: nil, object: nil, underlying: nil)
    }
}
