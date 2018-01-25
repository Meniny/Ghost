//
//  GhostResponse+URLResponse.swift
//  Ghost
//
//  Created by Elias Abel on 22/3/17.
//
//

import Foundation

extension GhostResponse {

    public init(_ response: URLResponse, _ ghostTask: GhostTask? = nil, _ responseObject: Any? = nil) {
        self.init(response.url, mimeType: response.mimeType, contentLength: response.expectedContentLength, textEncoding: response.textEncodingName, filename: response.suggestedFilename, ghostTask: ghostTask, responseObject: responseObject, response: response)
    }
    
}
