//
//  GhostURLSession+Download.swift
//  Ghost
//
//  Created by Elias Abel on 17/3/17.
//
//

extension GhostURLSession {

    open func download(_ resumeData: Data) -> GhostTask {
        var ghostDownloadTask: GhostTask?
        let task = session.downloadTask(withResumeData: resumeData) { [weak self] (url, response, error) in
            let ghostResponse = self?.ghostResponse(response, ghostDownloadTask, url)
            let ghostError = self?.ghostError(error, url, response)
            self?.process(ghostDownloadTask, ghostResponse, ghostError)
        }
        ghostDownloadTask = ghostTask(task)
        observe(task, ghostDownloadTask)
        return ghostDownloadTask!
    }

    open func download(_ request: GhostRequest) -> GhostTask {
        var ghostDownloadTask: GhostTask?
        let task = session.downloadTask(with: urlRequest(request)) { [weak self] (url, response, error) in
            let ghostResponse = self?.ghostResponse(response, ghostDownloadTask, url)
            let ghostError = self?.ghostError(error, url, response)
            self?.process(ghostDownloadTask, ghostResponse, ghostError)
        }
        ghostDownloadTask = ghostTask(task, request)
        observe(task, ghostDownloadTask)
        return ghostDownloadTask!
    }

    open func download(_ request: URLRequest) throws -> GhostTask {
        guard let ghostRequest = request.ghostRequest else {
            throw ghostError(URLError(.badURL))!
        }
        return download(ghostRequest)
    }

    open func download(_ url: URL, cachePolicy: GhostRequest.GhostCachePolicy? = nil, timeoutInterval: TimeInterval? = nil) -> GhostTask {
        return download(ghostRequest(url, cache: cachePolicy, timeout: timeoutInterval))
    }

    open func download(_ urlString: String, cachePolicy: GhostRequest.GhostCachePolicy? = nil, timeoutInterval: TimeInterval? = nil) throws -> GhostTask {
        guard let url = URL(string: urlString) else {
            throw ghostError(URLError(.badURL))!
        }
        return download(url, cachePolicy: cachePolicy, timeoutInterval: timeoutInterval)
    }

}
