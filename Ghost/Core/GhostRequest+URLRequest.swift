//
//  GhostRequest+URLRequest.swift
//  Ghost
//
//  Created by Elias Abel on 23/3/17.
//
//

import Foundation

extension GhostRequest {

    private struct HTTPHeader {
        static let contentLength = "Content-Length"
        static let contentType = "Content-Type"
        static let accept = "Accept"
        static let acceptEncoding = "Accept-Encoding"
        static let cacheControl = "Cache-Control"
        static let authorization = "Authorization"
    }

    public init?(_ urlRequest: URLRequest) {
        guard let url = urlRequest.url else {
            return nil
        }
        var contentType: GhostContentType? = nil
        if let contentTypeValue = urlRequest.value(forHTTPHeaderField: HTTPHeader.contentType) {
            contentType = GhostContentType(rawValue: contentTypeValue)
        }
        var accept: GhostContentType? = nil
        if let acceptValue = urlRequest.value(forHTTPHeaderField: HTTPHeader.accept) {
            accept = GhostContentType(rawValue: acceptValue)
        }
        var acceptEncoding: [GhostContentEncoding]? = nil
        if let acceptEncodingValue = urlRequest.value(forHTTPHeaderField: HTTPHeader.acceptEncoding) {
            acceptEncoding = acceptEncodingValue.components(separatedBy: ", ").flatMap({GhostContentEncoding(rawValue: $0)})
        }
        var cacheControl: [GhostCacheControl]? = nil
        if let cacheControlValue = urlRequest.value(forHTTPHeaderField: HTTPHeader.cacheControl) {
            cacheControl = cacheControlValue.components(separatedBy: ", ").flatMap({GhostCacheControl(rawValue: $0)})
        }
        var authorization = GhostAuthorization.none
        if let authorizationValue = urlRequest.value(forHTTPHeaderField: HTTPHeader.authorization) {
            authorization = GhostAuthorization(rawValue: authorizationValue)
        }
        var method = GhostMethod.GET
        if let methodString = urlRequest.httpMethod, let methodValue = GhostMethod(rawValue: methodString) {
            method = methodValue
        }
        var contentLength: GhostContentLength? = nil
        if let contentLengthValue = urlRequest.value(forHTTPHeaderField: HTTPHeader.contentLength), let contentLengthInt64 = GhostContentLength(contentLengthValue) {
            contentLength = contentLengthInt64
        }
        self.init(url, cache: GhostCachePolicy(rawValue: urlRequest.cachePolicy.rawValue) ?? .useProtocolCachePolicy, timeout: urlRequest.timeoutInterval, mainDocumentURL: urlRequest.mainDocumentURL, serviceType: GhostServiceType(rawValue: urlRequest.networkServiceType.rawValue) ?? .default, contentType: contentType, contentLength: contentLength, accept: accept, acceptEncoding: acceptEncoding, cacheControl: cacheControl, allowsCellularAccess: urlRequest.allowsCellularAccess, method: method, headers: urlRequest.allHTTPHeaderFields, body: urlRequest.httpBody, bodyStream: urlRequest.httpBodyStream, handleCookies: urlRequest.httpShouldHandleCookies, usePipelining: urlRequest.httpShouldUsePipelining, authorization: authorization)
    }

    public var urlRequest: URLRequest {
        var urlRequest = URLRequest(url: url, cachePolicy: URLRequest.CachePolicy(rawValue: cache.rawValue) ?? .useProtocolCachePolicy, timeoutInterval: timeout)
        urlRequest.mainDocumentURL = mainDocumentURL
        urlRequest.networkServiceType = URLRequest.NetworkServiceType(rawValue: serviceType.rawValue) ?? .default
        urlRequest.allowsCellularAccess = allowsCellularAccess
        urlRequest.httpMethod = httpMethod.rawValue
        urlRequest.allHTTPHeaderFields = headers
        urlRequest.setValue(contentType?.rawValue, forHTTPHeaderField: HTTPHeader.contentType)
        if let contentLength = contentLength {
            urlRequest.setValue("\(contentLength)", forHTTPHeaderField: HTTPHeader.contentLength)
        }
        urlRequest.setValue(accept?.rawValue, forHTTPHeaderField: HTTPHeader.accept)
        urlRequest.setValue(acceptEncoding?.flatMap({$0.rawValue}).joined(separator: ", "), forHTTPHeaderField: HTTPHeader.acceptEncoding)
        urlRequest.setValue(cacheControl?.flatMap({$0.rawValue}).joined(separator: ", "), forHTTPHeaderField: HTTPHeader.cacheControl)
        if authorization != .none {
            urlRequest.setValue(authorization.rawValue, forHTTPHeaderField: HTTPHeader.authorization)
        }
        if let body = body {
            urlRequest.httpBody = body
        } else if let bodyStream = bodyStream {
            urlRequest.httpBodyStream = bodyStream
        }
        urlRequest.httpShouldHandleCookies = handleCookies
        urlRequest.httpShouldUsePipelining = usePipelining
        return urlRequest
    }
    
}

extension URLRequest {

    public var ghostRequest: GhostRequest? {
        return GhostRequest(self)
    }

}
