//
//  GhostURLSession.swift
//  Ghost
//
//  Created by Elias Abel on 16/3/17.
//
//

import Foundation

open class GhostURLSession: Ghost {
    
    open static var shared: Ghost {
        return self.default
    }

    open static let `default` = GhostURLSession(URLSession.shared)

    open static let defaultCache: URLCache = {
        let defaultMemoryCapacity = 4 * 1024 * 1024
        let defaultDiskCapacity = 5 * defaultMemoryCapacity
        let cachesDirectoryURL = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first
        let cacheURL = cachesDirectoryURL?.appendingPathComponent(String(describing: GhostURLSession.self))
        var defaultDiskPath = cacheURL?.path
        #if os(OSX)
        defaultDiskPath = cacheURL?.absoluteString
        #endif
        return URLCache(memoryCapacity: defaultMemoryCapacity, diskCapacity: defaultDiskCapacity, diskPath: defaultDiskPath)
    }()

    open private(set) var session: URLSession!

    open var delegate: URLSessionDelegate? { return session.delegate }

    open var delegateQueue: OperationQueue { return session.delegateQueue }

    open var configuration: URLSessionConfiguration { return session.configuration }

    open var sessionDescription: String? {
        get {
            return session.sessionDescription
        }
        set {
            session.sessionDescription = newValue
        }
    }

    open var requestInterceptors = [RequestInterceptor]()

    open var responseInterceptors = [ResponseInterceptor]()

    open var retryClosure: GhostTask.RetryClosure?

    open private(set) var authChallenge: ((URLAuthenticationChallenge, (URLSession.AuthChallengeDisposition, URLCredential?) -> Swift.Void) -> Swift.Void)?

    open private(set) var serverTrust = [String: GhostServerTrust]()

    fileprivate final var taskObserver: GhostURLSessionTaskObserver? = GhostURLSessionTaskObserver()

    public convenience init() {
        let defaultConfiguration = URLSessionConfiguration.default
        defaultConfiguration.urlCache = GhostURLSession.defaultCache
        self.init(defaultConfiguration)
    }

    public init(_ urlSession: URLSession) {
        session = urlSession
    }

    public init(_ configuration: URLSessionConfiguration, delegateQueue: OperationQueue? = nil, delegate: URLSessionDelegate? = nil) {
        let sessionDelegate = delegate ?? GhostURLSessionDelegate(self)
        session = URLSession(configuration: configuration, delegate: sessionDelegate, delegateQueue: delegateQueue)
    }

    public init(_ configuration: URLSessionConfiguration, challengeQueue: OperationQueue? = nil, authenticationChallenge: @escaping (URLAuthenticationChallenge, (URLSession.AuthChallengeDisposition, URLCredential?) -> Swift.Void) -> Swift.Void) {
        session = URLSession(configuration: configuration, delegate: GhostURLSessionDelegate(self), delegateQueue: challengeQueue)
        authChallenge = authenticationChallenge
    }

    public init(_ configuration: URLSessionConfiguration, challengeQueue: OperationQueue? = nil, serverTrustPolicies: [String: GhostServerTrust]) {
        session = URLSession(configuration: configuration, delegate: GhostURLSessionDelegate(self), delegateQueue: challengeQueue)
        serverTrust = serverTrustPolicies
    }

    open func addRequestInterceptor(_ interceptor: @escaping RequestInterceptor) {
        requestInterceptors.append(interceptor)
    }

    open func addResponseInterceptor(_ interceptor: @escaping ResponseInterceptor) {
        responseInterceptors.append(interceptor)
    }

    deinit {
        taskObserver = nil
        authChallenge = nil
        retryClosure = nil
        session.invalidateAndCancel()
        session = nil
    }
    
}

extension GhostURLSession {

    func observe(_ task: URLSessionTask, _ ghostTask: GhostTask?) {
        taskObserver?.add(task, ghostTask)
        if let delegate = delegate as? GhostURLSessionDelegate {
            delegate.add(task, ghostTask)
        }
    }

    func urlRequest(_ ghostRequest: GhostRequest) -> URLRequest {
        var builder = ghostRequest.builder()
        requestInterceptors.forEach({ interceptor in
            builder = interceptor(builder)
        })
        return builder.build().urlRequest
    }

    func ghostRequest(_ url: URL, cache: GhostRequest.GhostCachePolicy? = nil, timeout: TimeInterval? = nil) -> GhostRequest {
        let cache = cache ?? GhostRequest.GhostCachePolicy(rawValue: session.configuration.requestCachePolicy.rawValue) ?? .useProtocolCachePolicy
        let timeout = timeout ?? session.configuration.timeoutIntervalForRequest
        return GhostRequest(url, cache: cache, timeout: timeout)
    }

    func ghostTask(_ urlSessionTask: URLSessionTask, _ request: GhostRequest? = nil) -> GhostTask {
        if let currentRequest = urlSessionTask.currentRequest {
            return GhostTask(urlSessionTask, request: currentRequest.ghostRequest)
        } else if let originalRequest = urlSessionTask.originalRequest {
            return GhostTask(urlSessionTask, request: originalRequest.ghostRequest)
        }
        return GhostTask(urlSessionTask, request: request)
    }

    func ghostResponse(_ response: URLResponse?, _ ghostTask: GhostTask? = nil, _ responseObject: Any? = nil) -> GhostResponse? {
        var ghostResponse: GhostResponse?
        if let httpResponse = response as? HTTPURLResponse {
            ghostResponse = GhostResponse(httpResponse, ghostTask, responseObject)
        } else if let response = response {
            ghostResponse = GhostResponse(response, ghostTask, responseObject)
        }
        guard let response = ghostResponse else {
            return nil
        }
        var builder = response.builder()
        responseInterceptors.forEach({ interceptor in
            builder = interceptor(builder)
        })
        return builder.build()
    }

    func ghostError(_ error: Error?, _ responseObject: Any? = nil, _ response: URLResponse? = nil) -> GhostError? {
        if let error = error {
            if let response = response as? HTTPURLResponse {
                return GhostError.responseError(from: error, code: response.statusCode)
            }
            return GhostError.ghost(code: error._code, message: error.localizedDescription, headers: (response as? HTTPURLResponse)?.allHeaderFields, object: responseObject, underlying: error)
        }
        if responseObject != nil {
            if let response = response as? HTTPURLResponse {
                return GhostError.responseError(from: error, code: response.statusCode)
            }            
        }
        return nil
    }

    func process(_ ghostTask: GhostTask?, _ ghostResponse: GhostResponse?, _ ghostError: GhostError?) {
        ghostTask?.response = ghostResponse
        ghostTask?.error = ghostError
        if let request = ghostTask?.request, let retryCount = ghostTask?.retryCount, ghostTask?.retryClosure?(ghostResponse, ghostError, retryCount) == true || retryClosure?(ghostResponse, ghostError, retryCount) == true {
            let retryTask = self.data(request)
            ghostTask?.ghostTask = retryTask.ghostTask
            ghostTask?.state = .suspended
            ghostTask?.retryCount += 1
            retryTask.request = nil
            retryTask.progressClosure = { progress in
                ghostTask?.progress = progress
                ghostTask?.progressClosure?(progress)
            }
            retryTask.completionClosure = { response, error in
                ghostTask?.metrics = retryTask.metrics
                self.process(ghostTask, response, error)
            }
            ghostTask?.resume()
        } else {
            ghostTask?.dispatchSemaphore?.signal()
            ghostTask?.completionClosure?(ghostResponse, ghostError)
        }
    }

}
