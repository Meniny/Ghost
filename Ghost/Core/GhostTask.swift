//
//  GhostTask.swift
//  Ghost
//
//  Created by Elias Abel on 25/3/17.
//
//

import Foundation

public typealias GhostTaskIdentifier = Int

public protocol GhostTaskProtocol: class {

    @available(iOS 11.0, tvOS 11.0, watchOS 4.0, macOS 10.13, *)
    var progress: Progress { get }

    @available(iOS 11.0, tvOS 11.0, watchOS 4.0, macOS 10.13, *)
    var earliestBeginDate: Date? { get set }

    func cancel()

    func suspend()

    func resume()

}

open class GhostTask {

    public enum GhostState : Int {
        case running, suspended, canceling, completed, waitingForConnectivity
    }

    open let identifier: GhostTaskIdentifier

    open var request: GhostRequest?

    open internal(set) var response: GhostResponse? {
        didSet {
            state = .completed
        }
    }

    open let taskDescription: String?

    open internal(set) var state: GhostState

    open internal(set) var error: GhostError? {
        didSet {
            state = .completed
        }
    }

    open internal(set) var priority: Float?

    open internal(set) var progress: Progress

    open internal(set) var metrics: GhostTaskMetrics?

    var ghostTask: GhostTaskProtocol?

    open internal(set) var retryCount: UInt = 0

    fileprivate(set) var dispatchSemaphore: DispatchSemaphore?

    var completionClosure: CompletionClosure?

    fileprivate(set) var retryClosure: RetryClosure?

    var progressClosure: ProgressClosure?

    public init(_ identifier: GhostTaskIdentifier? = nil, request: GhostRequest? = nil , response: GhostResponse? = nil, taskDescription: String? = nil, state: GhostState = .suspended, error: GhostError? = nil, priority: Float? = nil, progress: Progress? = nil, metrics: GhostTaskMetrics? = nil, task: GhostTaskProtocol? = nil) {
        self.request = request
        self.identifier = identifier ?? GhostTaskIdentifier(arc4random())
        self.response = response
        self.taskDescription = taskDescription ?? request?.description
        self.state = state
        self.error = error
        self.priority = priority
        if let progress = progress {
            self.progress = progress
        } else if #available(iOS 11.0, tvOS 11.0, watchOS 4.0, macOS 10.13, *), let progress = task?.progress {
            self.progress = progress
        } else {
            self.progress = Progress(totalUnitCount: Int64(request?.contentLength ?? 0))
        }
        self.ghostTask = task
    }

    deinit {
        completionClosure = nil
        progressClosure = nil
        retryClosure = nil
    }

}

extension GhostTask {

    public typealias CompletionClosure = (GhostResponse?, GhostError?) -> Swift.Void
    public typealias RetryClosure = (GhostResponse?, GhostError?, UInt) -> Bool

    @discardableResult open func async(_ completion: CompletionClosure? = nil) -> Self {
        guard state == .suspended else {
            return self
        }
        completionClosure = completion
        resume()
        return self
    }

    open func sync() throws -> GhostResponse {
        guard state == .suspended else {
            if let response = response {
                return response
            } else if let error = error {
                throw error
            } else {
                throw GhostError.ghost(code: error?.code, message: error?.message ?? "", headers: response?.headers, object: response?.responseObject, underlying: error?.underlying)
            }
        }
        dispatchSemaphore = DispatchSemaphore(value: 0)
        resume()
        let dispatchTimeoutResult = dispatchSemaphore?.wait(timeout: DispatchTime.distantFuture)
        if dispatchTimeoutResult == .timedOut {
            let urlError = URLError(.timedOut)
            error = GhostError.ghost(code: urlError._code, message: urlError.localizedDescription, headers: response?.headers, object: response?.responseObject, underlying: urlError)
        }
        if let error = error {
            throw error
        }
        return response!
    }

    open func cached() throws -> GhostResponse {
        if let response = response {
            return response
        }
        guard let urlRequest = request?.urlRequest else {
            guard let taskError = error else {
                let error = URLError(.resourceUnavailable)
                throw GhostError.ghost(code: error._code, message: "Request not found.", headers: response?.headers, object: response?.responseObject, underlying: error)
            }
            throw taskError
        }
        if let cachedResponse = URLCache.shared.cachedResponse(for: urlRequest) {
            return GhostResponse(cachedResponse, self)
        }
        guard let taskError = error else {
            let error = URLError(.resourceUnavailable)
            throw GhostError.ghost(code: error._code, message: "Cached response not found.", headers: response?.headers, object: response?.responseObject, underlying: error)
        }
        throw taskError
    }

    @discardableResult open func retry(_ retry: @escaping RetryClosure) -> Self {
        retryClosure = retry
        return self
    }

}

extension GhostTask {

    public typealias ProgressClosure = (Progress) -> Swift.Void

    @discardableResult open func progress(_ progressClosure: ProgressClosure?) -> Self {
        self.progressClosure = progressClosure
        return self
    }

}

extension GhostTask: GhostTaskProtocol {

    open var earliestBeginDate: Date? {
        get {
            guard #available(iOS 11.0, tvOS 11.0, watchOS 4.0, macOS 10.13, *) else {
                return nil
            }
            return ghostTask?.earliestBeginDate
        }
        set {
            if #available(iOS 11.0, tvOS 11.0, watchOS 4.0, macOS 10.13, *) {
                ghostTask?.earliestBeginDate = newValue
            }
        }
    }

    open func cancel() {
        state = .canceling
        ghostTask?.cancel()
    }

    open func suspend() {
        state = .suspended
        ghostTask?.suspend()
    }

    open func resume() {
        state = .running
        ghostTask?.resume()
    }

}

extension GhostTask: Hashable {

    open var hashValue: Int {
        return identifier.hashValue
    }
    
}

extension GhostTask: Equatable {

    open static func ==(lhs: GhostTask, rhs: GhostTask) -> Bool {
        return lhs.identifier == rhs.identifier
    }

}

extension GhostTask: CustomStringConvertible {

    open var description: String {
        var description = String(describing: GhostTask.self) + " " + identifier.description + " (" + String(describing: state) + ")"
        if let taskDescription = taskDescription {
            description = description + " " + taskDescription
        }
        return description
    }

}

extension GhostTask: CustomDebugStringConvertible {

    open var debugDescription: String {
        return description
    }
    
}
