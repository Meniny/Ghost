//
//  GhostResponse+CachedURLResponse.swift
//  Ghost
//
//  Created by Elias Abel on 22/3/17.
//
//

import Foundation

extension GhostResponse {

    public init(_ cachedResponse: CachedURLResponse, _ ghostTask: GhostTask? = nil) {
        self.init(cachedResponse.response.url, mimeType: cachedResponse.response.mimeType, contentLength: cachedResponse.response.expectedContentLength, textEncoding: cachedResponse.response.textEncodingName, filename: cachedResponse.response.suggestedFilename, userInfo: cachedResponse.userInfo, ghostTask: ghostTask, responseObject: cachedResponse.data)
    }
    
}
