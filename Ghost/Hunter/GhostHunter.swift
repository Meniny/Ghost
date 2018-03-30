
import Foundation
import Ghost

// MARK: - Enums

public enum GhostHunterDispatch {
    case asynchronously
    case synchronously
}

public enum GhostHunterBodyType {
    case string(String, encoding: String.Encoding, lossy: Bool)
//    case json(Encodable)
//    case plist(Encodable)
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

internal struct Spoil {
    
    internal var session: GhostURLSession {
        return GhostURLSession.default
    }
    internal var ghost: Ghost {
        return self.session
    }
    internal var method: GhostRequest.GhostMethod
    internal var dispatch: GhostHunterDispatch
    internal var url: URL?
    internal var parameters: [String: Any]?
    internal var headers: [String: String]?
    internal var accept: GhostContentType?
    internal var cachePolicy: GhostRequest.GhostCachePolicy
    internal var cacheControls: [GhostCacheControl]?
    internal var timeout: TimeInterval
    internal var body: GhostHunterBodyType?
    internal var contentType: GhostContentType?
    internal var serviceType: GhostRequest.GhostServiceType
    internal private(set) var requestBuiler: GhostRequest.Builder
    
    public init(_ method: GhostRequest.GhostMethod,
                _ dispatch: GhostHunterDispatch,
                url: URL,
                parameters: [String: Any]?,
                headers: [String: String]?,
                accept: GhostContentType? = nil,
                cachePolicy: GhostRequest.GhostCachePolicy = NightWatchDefaultCachePolicy,
                cacheControls: [GhostCacheControl]? = NightWatchDefaultCacheControls,
                timeout: TimeInterval = NightWatchDefaultTimeout,
                body: GhostHunterBodyType? = nil,
                contentType: GhostContentType? = nil,
                serviceType: GhostRequest.GhostServiceType = NightWatchDefaultServiceType) throws {
        
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
//                case .json(let json):
//                    try self.requestBuiler.setJSONObject(json as? Encodable)
//                    break
                case .plistObject(let plist, let format, let options):
                    try self.requestBuiler.setPlistBody(plist, format: format, options: options)
                    break
//                case .plist(let plist):
//                    try self.requestBuiler.setPlistObject(plist as? Encodable)
//                    break
                case .multipartFormData(let data):
                    try self.requestBuiler.setMultipartFormData(data)
                    break
                }
            }
        } catch {
            throw error//GhostError.ghostError(from: error)
        }
    }
    
    internal func build() -> GhostRequest {
        let request = self.requestBuiler.build()
        return request
    }
    
    @discardableResult
    internal func async(progress: GhostTask.ProgressClosure?, completion: GhostTask.CompletionClosure?) -> Spoil {
        let request = self.build()
        self.ghost.data(request).progress(progress).async(completion)
        return self
    }
    
    @discardableResult
    internal func sync(progress: GhostTask.ProgressClosure?, completion: GhostTask.CompletionClosure?) throws -> Spoil {
        let request = self.build()
        do {
            let response = try self.ghost.data(request).progress(progress).sync()
            completion?(response, nil)
        } catch {
            throw error//GhostError.ghostError(from: error)
        }
        return self
    }
    
    @discardableResult
    internal func go(progress: GhostTask.ProgressClosure?, completion: GhostTask.CompletionClosure?) throws -> Spoil {
        switch self.dispatch {
        case .asynchronously:
            self.async(progress: progress, completion: completion)
            break
        case .synchronously:
            try self.sync(progress: progress, completion: completion)
            break
        }
        return self
    }
}

public struct GhostHunter {
    
    internal var spoil: Spoil? = nil
    
    internal init() {}
    
    internal init(spoil: Spoil) {
        self.spoil = spoil
    }
}

// MARK: - Class Methods - Requests
public extension GhostHunter {
    @discardableResult
    public static func async(_ method: GhostRequest.GhostMethod,
                             url: URL,
                             parameters: [String: Any]?,
                             headers: [String: String]?,
                             body: GhostHunterBodyType? = nil,
                             contentType: GhostContentType? = nil,
                             progress: GhostTask.ProgressClosure?,
                             completion: GhostTask.CompletionClosure?) throws -> GhostHunter {
        return try GhostHunter.request(method, .asynchronously,
                                url: url,
                                parameters: parameters,
                                headers: headers,
                                body: body,
                                contentType: contentType,
                                progress: progress,
                                completion: completion)
    }
    
    @discardableResult
    public static func sync(_ method: GhostRequest.GhostMethod,
                            url: URL,
                            parameters: [String: Any]?,
                            headers: [String: String]?,
                            body: GhostHunterBodyType? = nil,
                            contentType: GhostContentType? = nil,
                            progress: GhostTask.ProgressClosure?,
                            completion: GhostTask.CompletionClosure?) throws -> GhostHunter {
        do {
            let hunter = try GhostHunter.request(method, .synchronously,
                                                 url: url,
                                                 parameters: parameters,
                                                 headers: headers,
                                                 body: body,
                                                 contentType: contentType,
                                                 progress: progress,
                                                 completion: completion)
        } catch {
            throw error
        }
        
        throw GhostError.unknown
    }
    
    @discardableResult
    public static func request(_ method: GhostRequest.GhostMethod,
                               _ dispatch: GhostHunterDispatch,
                               url: URL,
                               parameters: [String: Any]?,
                               headers: [String: String]?,
                               accept: GhostContentType? = nil,
                               cachePolicy: GhostRequest.GhostCachePolicy = NightWatchDefaultCachePolicy,
                               cacheControls: [GhostCacheControl]? = NightWatchDefaultCacheControls,
                               timeout: TimeInterval = NightWatchDefaultTimeout,
                               body: GhostHunterBodyType? = nil,
                               contentType: GhostContentType? = nil,
                               serviceType: GhostRequest.GhostServiceType = NightWatchDefaultServiceType,
                               progress: GhostTask.ProgressClosure?,
                               completion: GhostTask.CompletionClosure?) throws -> GhostHunter {
        var hunter = GhostHunter.init()
        do {
            hunter.spoil = try Spoil.init(method, dispatch,
                                          url: url,
                                          parameters: parameters,
                                          headers: headers,
                                          accept: accept,
                                          cachePolicy: cachePolicy,
                                          cacheControls: cacheControls,
                                          timeout: timeout,
                                          body: body,
                                          contentType: contentType,
                                          serviceType: serviceType)
            try hunter.spoil?.go(progress: progress, completion: completion)
        } catch {
            throw error
        }
        return hunter
    }
}

// MARK: - Class Methods - Uploading/Downloading

public extension GhostHunter {
    @discardableResult
    public static func uploadMultipartForm(_ file: URL,
                                           name: String,
                                           mimeType: String,
                                           to url: URL,
                                           method: GhostRequest.GhostMethod = .POST,
                                           headers: [String: String]?,
                                           progress: GhostTask.ProgressClosure?,
                                           completion: GhostTask.CompletionClosure?) throws -> GhostHunter {
        let multipartFormData = GhostMultipartFormData.init()
        multipartFormData.append(file, withName: name, fileName: name, mimeType: mimeType)
        do {
            let hunter = try GhostHunter.request(method,
                                                 .asynchronously,
                                                 url: url,
                                                 parameters: nil,
                                                 headers: headers,
                                                 accept: nil,
                                                 cachePolicy: NightWatchDefaultCachePolicy,
                                                 cacheControls: NightWatchDefaultCacheControls,
                                                 timeout: NightWatchDefaultTimeout,
                                                 body: GhostHunterBodyType.multipartFormData(multipartFormData),
                                                 contentType: nil,
                                                 serviceType: NightWatchDefaultServiceType,
                                                 progress: progress,
                                                 completion: completion)
            return hunter
        } catch {
            throw error
        }
        throw GhostError.unknown
    }
    
    public static func upload(data: Data,
                              to url: URL,
                              parameters: [String: Any]? = nil,
                              headers: [String: String]? = nil,
                              method: GhostRequest.GhostMethod = .POST,
                              progress: GhostTask.ProgressClosure?,
                              completion: GhostTask.CompletionClosure?) {
        let session = GhostURLSession.default
        let builder = GhostRequest.init(url).builder()
            .setURLParameters(parameters)
            .setHeaders(headers)
            .setMethod(method)
        let request = builder.build()
        session.upload(request, data: data).progress(progress).async(completion)
    }
    
    public static func upload(file: URL,
                              to url: URL,
                              parameters: [String: Any]? = nil,
                              headers: [String: String]? = nil,
                              method: GhostRequest.GhostMethod = .POST,
                              progress: GhostTask.ProgressClosure?,
                              completion: GhostTask.CompletionClosure?) {
        let session = GhostURLSession.default
        let builder = GhostRequest.init(url).builder()
            .setURLParameters(parameters)
            .setHeaders(headers)
            .setMethod(method)
        let request = builder.build()
        session.upload(request, fileURL: file).progress(progress).async(completion)
    }
    
    public static func upload(streamFile file: URL,
                              to url: URL,
                              parameters: [String: Any]? = nil,
                              headers: [String: String]? = nil,
                              method: GhostRequest.GhostMethod = .POST,
                              progress: GhostTask.ProgressClosure?,
                              completion: GhostTask.CompletionClosure?) {
        let session = GhostURLSession.default
        let stream = InputStream.init(fileAtPath: file.path)
        let builder = GhostRequest.init(url, bodyStream: stream).builder()
            .setURLParameters(parameters)
            .setHeaders(headers)
            .setMethod(method)
        let request = builder.build()
        session.upload(request).progress(progress).async(completion)
    }
    
    public static func download(_ url: URL,
                                progress: GhostTask.ProgressClosure?,
                                completion: GhostTask.CompletionClosure?) {
        let session = GhostURLSession.default
        let request = GhostRequest.init(url)
        session.download(request).progress(progress).async(completion)
    }
    
    public static func download(resumeData: Data,
                                progress: GhostTask.ProgressClosure?,
                                completion: GhostTask.CompletionClosure?) {
        let session = GhostURLSession.default
        session.download(resumeData).progress(progress).async(completion)
    }
}

