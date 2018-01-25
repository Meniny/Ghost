
import Foundation

// MARK: - Enums

public enum NightWatchDispatch {
    case asynchronously
    case synchronously
}

public enum NightWatchBody {
    case string(String, encoding: String.Encoding, lossy: Bool)
    case json(Encodable)
    case plist(Encodable)
    case jsonObject([String: Any], options: JSONSerialization.WritingOptions)
    case plistObject([String: Any], format: PropertyListSerialization.PropertyListFormat, options: PropertyListSerialization.WriteOptions)
    case stream(InputStream)
    case multipartFormData(GhostMultipartFormData)
    case custom(Data)
}
// MARK: - Default Values

public var NightWatchDefaultTimeout: TimeInterval = 120
public var NightWatchDefaultCachePolicy: GhostRequest.GhostCachePolicy = .reloadIgnoringLocalCacheData
public var NightWatchDefaultCacheControls: [GhostCacheControl] = [.maxAge(500)]
public var NightWatchDefaultServiceType: GhostRequest.GhostServiceType = .default

// MARK: - Night Basic

open class NightWatch {
    
    open let ghost: Ghost
    open var method: GhostRequest.GhostMethod = .GET
    open var dispatch: NightWatchDispatch = .asynchronously
    open var url: URL? = nil
    open var parameters: [String: Any]? = nil
    open var headers: [String: String]? = nil
    open var accept: GhostContentType? = nil
    open var cachePolicy: GhostRequest.GhostCachePolicy = NightWatchDefaultCachePolicy
    open var cacheControls: [GhostCacheControl]? = NightWatchDefaultCacheControls
    open var timeout: TimeInterval = NightWatchDefaultTimeout
    open var body: NightWatchBody? = nil
    open var contentType: GhostContentType? = nil
    open var serviceType: GhostRequest.GhostServiceType = NightWatchDefaultServiceType
    open private(set) var requestBuiler: GhostRequest.Builder
    
    public required init(_ method: GhostRequest.GhostMethod,
                         _ dispatch: NightWatchDispatch,
                         url: URL,
                         parameters: [String: Any]?,
                         headers: [String: String]?,
                         accept: GhostContentType? = nil,
                         cachePolicy: GhostRequest.GhostCachePolicy = NightWatchDefaultCachePolicy,
                         cacheControls: [GhostCacheControl]? = NightWatchDefaultCacheControls,
                         timeout: TimeInterval = NightWatchDefaultTimeout,
                         body: NightWatchBody? = nil,
                         contentType: GhostContentType? = nil,
                         serviceType: GhostRequest.GhostServiceType = NightWatchDefaultServiceType) throws {
        
        self.ghost = GhostURLSession.shared
        self.method = method
        self.dispatch = dispatch
        self.url = url
        self.parameters = parameters
        self.headers = headers
        self.accept = accept
        self.cachePolicy = cachePolicy
        self.cacheControls = cacheControls
        self.timeout = timeout
        self.body = body
        self.contentType = contentType
        self.serviceType = serviceType
        
        do {
            self.requestBuiler = try GhostRequest.builder(url)
            self.requestBuiler.setMethod(method)
                .setURLParameters(parameters)
                .setTimeout(timeout)
                .setHeaders(headers)
                .setAccept(accept)
                .setCache(cachePolicy)
                .setContentType(contentType)
                .setServiceType(serviceType)
                .setCacheControls(cacheControls)
            
            if let body = body, let contentType = contentType {
                switch body {
                case .custom(let data):
                    self.requestBuiler.setCustomBody(data, contentType: contentType)
                    break
                case .string(let string, let encoding, let lossy):
                    self.requestBuiler.setStringBody(string, encoding: encoding, allowLossyConversion: lossy)
                    break
                case .stream(let stream):
                    self.requestBuiler.setBodyStream(stream)
                    break
                case .jsonObject(let json, let options):
                    try self.requestBuiler.setJSONBody(json, options: options)
                    break
                case .json(let json):
                    try self.requestBuiler.setJSONObject(json as? Encodable)
                    break
                case .plistObject(let plist, let format, let options):
                    try self.requestBuiler.setPlistBody(plist, format: format, options: options)
                    break
                case .plist(let plist):
                    try self.requestBuiler.setPlistObject(plist as? Encodable)
                    break
                case .multipartFormData(let data):
                    try self.requestBuiler.setMultipartFormData(data)
                    break
                }
            }
        } catch {
            throw GhostError.ghostError(from: error)
        }
    }
    
    @discardableResult
    open func async(_ completion: GhostTask.CompletionClosure?) -> Self {
        let request = self.requestBuiler.build()
        self.ghost.data(request).async(completion)
        return self
    }
    
    @discardableResult
    open func sync(_ completion: GhostTask.CompletionClosure?) throws -> Self {
        let request = self.requestBuiler.build()
        do {
            let response = try self.ghost.data(request).sync()
            completion?(response, nil)
        } catch {
            throw GhostError.ghostError(from: error)
        }
        return self
    }
    
    @discardableResult
    open func go(_ completion: GhostTask.CompletionClosure?) throws -> Self {
        switch self.dispatch {
        case .asynchronously:
            self.async(completion)
            break
        case .synchronously:
            try self.sync(completion)
            break
        }
        return self
    }
}

// MARK: - Errors

public extension GhostError {
    public static func ghostError(from error: Error) -> GhostError {
        return GhostError.ghost(code: error._code,
                                message: error.localizedDescription,
                                headers: nil,
                                object: nil,
                                underlying: error)
    }
    
    public static func parseError(from error: Error) -> GhostError {
        return GhostError.parse(code: error._code,
                                message: error.localizedDescription,
                                object: nil,
                                underlying: error)
    }
}

// MARK: - typealias GhostHunter

public typealias GhostHunter = NightWatch

// MARK: - Class Methods - Requests
public extension NightWatch {
    @discardableResult
    open class func async(_ method: GhostRequest.GhostMethod,
                          url: URL,
                          parameters: [String: Any]?,
                          headers: [String: String]?,
                          body: NightWatchBody? = nil,
                          contentType: GhostContentType? = nil,
                          completion: GhostTask.CompletionClosure?) throws -> Self {
        return try self.request(method, .asynchronously,
                                url: url,
                                parameters: parameters,
                                headers: headers,
                                body: body,
                                contentType: contentType,
                                completion: completion)
    }
    
    @discardableResult
    open class func sync(_ method: GhostRequest.GhostMethod,
                         url: URL,
                         parameters: [String: Any]?,
                         headers: [String: String]?,
                         body: NightWatchBody? = nil,
                         contentType: GhostContentType? = nil,
                         completion: GhostTask.CompletionClosure?) throws -> Self {
        return try self.request(method, .synchronously,
                                url: url,
                                parameters: parameters,
                                headers: headers,
                                body: body,
                                contentType: contentType,
                                completion: completion)
    }
    
    @discardableResult
    open class func request(_ method: GhostRequest.GhostMethod,
                            _ dispatch: NightWatchDispatch,
                            url: URL,
                            parameters: [String: Any]?,
                            headers: [String: String]?,
                            accept: GhostContentType? = nil,
                            cachePolicy: GhostRequest.GhostCachePolicy = NightWatchDefaultCachePolicy,
                            cacheControls: [GhostCacheControl]? = NightWatchDefaultCacheControls,
                            timeout: TimeInterval = NightWatchDefaultTimeout,
                            body: NightWatchBody? = nil,
                            contentType: GhostContentType? = nil,
                            serviceType: GhostRequest.GhostServiceType = NightWatchDefaultServiceType,
                            completion: GhostTask.CompletionClosure?) throws -> Self {
        return try self._request(method,
                                 dispatch,
                                 url: url,
                                 parameters: parameters,
                                 headers: headers,
                                 accept: accept,
                                 cachePolicy: cachePolicy,
                                 cacheControls: cacheControls,
                                 timeout: timeout,
                                 body: body,
                                 contentType: contentType,
                                 serviceType: serviceType,
                                 completion: completion)
    }
    
    private class func _request<T: NightWatch>(_ method: GhostRequest.GhostMethod,
                                               _ dispatch: NightWatchDispatch,
                                               url: URL,
                                               parameters: [String: Any]?,
                                               headers: [String: String]?,
                                               accept: GhostContentType?,
                                               cachePolicy: GhostRequest.GhostCachePolicy,
                                               cacheControls: [GhostCacheControl]?,
                                               timeout: TimeInterval,
                                               body: NightWatchBody?,
                                               contentType: GhostContentType?,
                                               serviceType: GhostRequest.GhostServiceType,
                                               completion: GhostTask.CompletionClosure?) throws -> T {
        return try self.init(method, dispatch,
                             url: url,
                             parameters: parameters,
                             headers: headers,
                             accept: accept,
                             cachePolicy: cachePolicy,
                             cacheControls: cacheControls,
                             timeout: timeout,
                             body: body,
                             contentType: contentType,
                             serviceType: serviceType).go(completion) as! T
    }
}

// MARK: - Class Methods - Uploading/Downloading

public extension NightWatch {
    @discardableResult
    open class func upload(_ file: URL,
                           name: String,
                           mimeType: String,
                           to url: URL,
                           method: GhostRequest.GhostMethod = .POST,
                           headers: [String: String]?,
                           completion: GhostTask.CompletionClosure?) throws -> Self {
        return try self._upload(file,
                                name: name,
                                mimeType: mimeType,
                                to: url,
                                method: method,
                                headers: headers,
                                completion: completion)
    }
    
    @discardableResult
    open class func _upload<T: NightWatch>(_ file: URL,
                                           name: String,
                                           mimeType: String,
                                           to url: URL,
                                           method: GhostRequest.GhostMethod = .POST,
                                           headers: [String: String]?,
                                           completion: GhostTask.CompletionClosure?) throws -> T {
        let multipartFormBody = GhostMultipartFormData.init()
        multipartFormBody.append(file, withName: name, fileName: name, mimeType: mimeType)
        let watch = try self.init(method, .asynchronously,
                                  url: url,
                                  parameters: nil,
                                  headers: headers,
                                  accept: nil,
                                  cachePolicy: NightWatchDefaultCachePolicy,
                                  cacheControls: NightWatchDefaultCacheControls,
                                  timeout: NightWatchDefaultTimeout,
                                  body: NightWatchBody.multipartFormData(multipartFormBody),
                                  contentType: GhostContentType.custom(mimeType),
                                  serviceType: NightWatchDefaultServiceType)
        try watch.go(completion)
        return watch as! T
    }
}
