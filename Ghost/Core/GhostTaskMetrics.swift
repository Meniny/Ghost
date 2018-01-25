//
//  GhostTaskMetrics.swift
//  Ghost
//
//  Created by Elias Abel on 25/3/17.
//
//

import Foundation

public struct GhostTaskMetrics {

    public struct GhostTransactionMetrics {

        public enum GhostResourceFetchType : Int {
            case unknown, networkLoad, serverPush, localCache
        }

        public let request: GhostRequest?

        public let response: GhostResponse?

        public let fetchStartDate: Date?

        public let domainLookupStartDate: Date?

        public let domainLookupEndDate: Date?

        public let connectStartDate: Date?

        public let secureConnectionStartDate: Date?

        public let secureConnectionEndDate: Date?

        public let connectEndDate: Date?

        public let requestStartDate: Date?

        public let requestEndDate: Date?

        public let responseStartDate: Date?

        public let responseEndDate: Date?

        public let networkProtocolName: String?

        public let isProxyConnection: Bool

        public let isReusedConnection: Bool

        public let resourceFetchType: GhostResourceFetchType

    }

    public let transactionMetrics: [GhostTransactionMetrics]

    public let taskInterval: TimeInterval

    public let redirectCount: Int
    
}
