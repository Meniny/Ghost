//
//  Ghost.swift
//  Ghost
//
//  Created by Elias Abel on 22/3/17.
//
//

import Foundation

public let kGhostSymbol = "👻"

public typealias RequestInterceptor = (GhostRequest.Builder) -> GhostRequest.Builder

public typealias ResponseInterceptor = (GhostResponse.Builder) -> GhostResponse.Builder

public protocol Ghost: class {

    static var shared: Ghost { get }

    var requestInterceptors: [RequestInterceptor] { get set }

    var responseInterceptors: [ResponseInterceptor] { get set }

    var retryClosure: GhostTask.RetryClosure? { get set }

    func addRequestInterceptor(_ interceptor: @escaping RequestInterceptor)

    func addResponseInterceptor(_ interceptor: @escaping ResponseInterceptor)

    func data(_ request: GhostRequest) -> GhostTask

    func download(_ resumeData: Data) -> GhostTask

    func download(_ request: GhostRequest) -> GhostTask

    func upload(_ streamedRequest: GhostRequest) -> GhostTask

    func upload(_ request: GhostRequest, data: Data) -> GhostTask

    func upload(_ request: GhostRequest, fileURL: URL) -> GhostTask

    #if !os(watchOS)
    @available(iOS 9.0, macOS 10.11, *)
    func stream(_ service: NetService) -> GhostTask

    @available(iOS 9.0, macOS 10.11, *)
    func stream(_ domain: String, type: String, name: String, port: Int32?) -> GhostTask

    @available(iOS 9.0, macOS 10.11, *)
    func stream(_ hostName: String, port: Int) -> GhostTask
    #endif

}
