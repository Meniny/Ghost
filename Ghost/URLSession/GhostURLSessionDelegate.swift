//
//  GhostURLSessionDelegate.swift
//  Ghost
//
//  Created by Elias Abel on 17/3/17.
//
//

import Foundation

class GhostURLSessionDelegate: NSObject {

    fileprivate weak final var ghostURLSession: GhostURLSession?

    final var tasks = [URLSessionTask: GhostTask]()

    init(_ urlSession: GhostURLSession) {
        ghostURLSession = urlSession
        super.init()
    }

    func add(_ task: URLSessionTask, _ ghostTask: GhostTask?) {
        tasks[task] = ghostTask
    }

    deinit {
        tasks.removeAll()
        ghostURLSession = nil
    }

}

extension GhostURLSessionDelegate: URLSessionDelegate {}

extension GhostURLSessionDelegate: URLSessionTaskDelegate {

    func urlSession(_ session: URLSession, task: URLSessionTask, didReceive challenge: URLAuthenticationChallenge, completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Swift.Void) {
        handle(challenge, tasks[task], completion: completionHandler)
    }

    @available(iOS 10.0, tvOS 10.0, watchOS 3.0, macOS 10.12, *)
    func urlSession(_ session: URLSession, task: URLSessionTask, didFinishCollecting taskMetrics: URLSessionTaskMetrics) {
        if let ghostTask = tasks[task] {
            ghostTask.metrics = GhostTaskMetrics(taskMetrics, request: ghostTask.request, response: ghostTask.response)
        }
        tasks[task] = nil
    }

    @available(iOS 11.0, tvOS 11.0, watchOS 4.0, macOS 10.13, *)
    func urlSession(_ session: URLSession, task: URLSessionTask, willBeginDelayedRequest request: URLRequest, completionHandler: @escaping (URLSession.DelayedRequestDisposition, URLRequest?) -> Void) {
        completionHandler(.continueLoading, nil)
    }

    @available(iOS 11.0, tvOS 11.0, watchOS 4.0, macOS 10.13, *)
    func urlSession(_ session: URLSession, taskIsWaitingForConnectivity task: URLSessionTask) {
        if let ghostTask = tasks[task] {
            ghostTask.state = .waitingForConnectivity
        }
    }

}

extension GhostURLSessionDelegate: URLSessionDataDelegate {}


extension GhostURLSessionDelegate: URLSessionDownloadDelegate {

    func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didFinishDownloadingTo location: URL) {}
    
}

@available(iOS 9.0, *)
extension GhostURLSessionDelegate: URLSessionStreamDelegate {}

extension GhostURLSessionDelegate {

    fileprivate func handle(_ challenge: URLAuthenticationChallenge, _ ghostTask: GhostTask? = nil, completion: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Swift.Void) {
        guard let authChallenge = ghostURLSession?.authChallenge else {
            guard challenge.previousFailureCount == 0 else {
                challenge.sender?.cancel(challenge)
                if let realm = challenge.protectionSpace.realm {
                    print(realm)
                    print(challenge.protectionSpace.authenticationMethod)
                }
                completion(.cancelAuthenticationChallenge, nil)
                return
            }

            var credential: URLCredential? = challenge.proposedCredential

            if credential?.hasPassword != true, challenge.protectionSpace.authenticationMethod == NSURLAuthenticationMethodHTTPBasic || challenge.protectionSpace.authenticationMethod == NSURLAuthenticationMethodHTTPDigest, let request = ghostTask?.request {
                switch request.authorization {
                case .basic(let user, let password):
                    credential = URLCredential(user: user, password: password, persistence: .forSession)
                default:
                    break
                }
            }

            if credential == nil, challenge.protectionSpace.authenticationMethod == NSURLAuthenticationMethodServerTrust, let serverTrust = challenge.protectionSpace.serverTrust {
                let host = challenge.protectionSpace.host
                if let policy = ghostURLSession?.serverTrust[host] {
                    if policy.evaluate(serverTrust, host: host) {
                        credential = URLCredential(trust: serverTrust)
                    } else {
                        credential = nil
                    }
                } else {
                    credential = URLCredential(trust: serverTrust)
                }
            }

            completion(credential != nil ? .useCredential : .cancelAuthenticationChallenge, credential)
            return
        }
        authChallenge(challenge, completion)
    }

}
