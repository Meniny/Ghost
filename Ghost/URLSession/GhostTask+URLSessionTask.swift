//
//  GhostTask+URLSessionTask.swift
//  Ghost
//
//  Created by Elias Abel on 25/3/17.
//
//

import Foundation

extension GhostTask {

    public convenience init(_ urlSessionTask: URLSessionTask, request: GhostRequest? = nil, response: GhostResponse? = nil, error: GhostError? = nil) {
        self.init(urlSessionTask.taskIdentifier, request: request, response: response, taskDescription: urlSessionTask.taskDescription, state: GhostState(rawValue: urlSessionTask.state.rawValue) ?? .suspended, error: error, priority: urlSessionTask.priority, task: urlSessionTask)
    }
    
}

extension URLSessionTask: GhostTaskProtocol {}
