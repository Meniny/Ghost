//
//  GhostURLSession+Upload.swift
//  Ghost
//
//  Created by Elias Abel on 17/3/17.
//
//

extension GhostURLSession {

    open func upload(_ streamedRequest: GhostRequest) -> GhostTask {
        let task = session.uploadTask(withStreamedRequest: urlRequest(streamedRequest))
        let ghostUploadTask = ghostTask(task, streamedRequest)
        observe(task, ghostUploadTask)
        return ghostUploadTask
    }

    open func upload(_ streamedRequest: URLRequest) throws -> GhostTask {
        guard let ghostRequest = streamedRequest.ghostRequest else {
            throw ghostError(URLError(.badURL))!
        }
        return upload(ghostRequest)
    }

    open func upload(_ streamedURL: URL, cachePolicy: GhostRequest.GhostCachePolicy? = nil, timeoutInterval: TimeInterval? = nil) -> GhostTask {
        return upload(ghostRequest(streamedURL, cache: cachePolicy, timeout: timeoutInterval))
    }

    open func upload(_ streamedURLString: String, cachePolicy: GhostRequest.GhostCachePolicy? = nil, timeoutInterval: TimeInterval? = nil) throws -> GhostTask {
        guard let url = URL(string: streamedURLString) else {
            throw ghostError(URLError(.badURL))!
        }
        return upload(url, cachePolicy: cachePolicy, timeoutInterval: timeoutInterval)
    }

    open func upload(_ request: GhostRequest, data: Data) -> GhostTask {
        var ghostUploadTask: GhostTask?
        let task = session.uploadTask(with: urlRequest(request), from: data) { [weak self] (data, response, error) in
            let ghostResponse = self?.ghostResponse(response, ghostUploadTask, data)
            let ghostError = self?.ghostError(error, data, response)
            self?.process(ghostUploadTask, ghostResponse, ghostError)
        }
        ghostUploadTask = ghostTask(task, request)
        observe(task, ghostUploadTask)
        return ghostUploadTask!
    }

    open func upload(_ request: URLRequest, data: Data) throws -> GhostTask {
        guard let ghostRequest = request.ghostRequest else {
            throw ghostError(URLError(.badURL))!
        }
        return upload(ghostRequest, data: data)
    }

    open func upload(_ url: URL, data: Data, cachePolicy: GhostRequest.GhostCachePolicy? = nil, timeoutInterval: TimeInterval? = nil) -> GhostTask {
        return upload(ghostRequest(url, cache: cachePolicy, timeout: timeoutInterval), data: data)
    }

    open func upload(_ urlString: String, data: Data, cachePolicy: GhostRequest.GhostCachePolicy? = nil, timeoutInterval: TimeInterval? = nil) throws -> GhostTask {
        guard let url = URL(string: urlString) else {
            throw ghostError(URLError(.badURL))!
        }
        return upload(url, data: data, cachePolicy: cachePolicy, timeoutInterval: timeoutInterval)
    }

    open func upload(_ request: GhostRequest, fileURL: URL) -> GhostTask {
        var ghostUploadTask: GhostTask?
        let task = session.uploadTask(with: urlRequest(request), fromFile: fileURL) { [weak self] (data, response, error) in
            let ghostResponse = self?.ghostResponse(response, ghostUploadTask, data)
            let ghostError = self?.ghostError(error, data, response)
            self?.process(ghostUploadTask, ghostResponse, ghostError)
        }
        ghostUploadTask = ghostTask(task, request)
        observe(task, ghostUploadTask)
        return ghostUploadTask!
    }

    open func upload(_ request: URLRequest, fileURL: URL) throws -> GhostTask {
        guard let ghostRequest = request.ghostRequest else {
            throw ghostError(URLError(.badURL))!
        }
        return upload(ghostRequest, fileURL: fileURL)
    }

    open func upload(_ url: URL, fileURL: URL, cachePolicy: GhostRequest.GhostCachePolicy? = nil, timeoutInterval: TimeInterval? = nil) -> GhostTask {
        return upload(ghostRequest(url, cache: cachePolicy, timeout: timeoutInterval), fileURL: fileURL)
    }

    open func upload(_ urlString: String, fileURL: URL, cachePolicy: GhostRequest.GhostCachePolicy? = nil, timeoutInterval: TimeInterval? = nil) throws -> GhostTask {
        guard let url = URL(string: urlString) else {
            throw ghostError(URLError(.badURL))!
        }
        return upload(url, fileURL: fileURL, cachePolicy: cachePolicy, timeoutInterval: timeoutInterval)
    }

}
