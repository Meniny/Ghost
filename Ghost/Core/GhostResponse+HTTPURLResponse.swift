//
//  GhostResponse+HTTPURLResponse.swift
//  Ghost
//
//  Created by Elias Abel on 22/3/17.
//
//

import Foundation

extension GhostResponse {

    public init(_ httpResponse: HTTPURLResponse, _ ghostTask: GhostTask? = nil, _ responseObject: Any? = nil) {
        self.init(httpResponse.url, mimeType: httpResponse.mimeType, contentLength: httpResponse.expectedContentLength, textEncoding: httpResponse.textEncodingName, filename: httpResponse.suggestedFilename, statusCode: httpResponse.statusCode, headers: httpResponse.allHeaderFields, localizedDescription: HTTPURLResponse.localizedString(forStatusCode: httpResponse.statusCode), ghostTask: ghostTask, responseObject: responseObject)
    }

}
