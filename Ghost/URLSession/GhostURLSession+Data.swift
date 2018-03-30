//
//  GhostURLSession+Data.swift
//  Ghost
//
//  Created by Elias Abel on 17/3/17.
//
//

extension GhostURLSession {

    open func data(_ request: GhostRequest) -> GhostTask {
        var ghostDataTask: GhostTask?
        let task = session.dataTask(with: urlRequest(request)) { [weak self] (data, response, error) in
            let ghostResponse = self?.ghostResponse(response, ghostDataTask, data)
            let ghostError = self?.ghostError(error, data, response)
            self?.process(ghostDataTask, ghostResponse, ghostError)
        }
        ghostDataTask = ghostTask(task, request)
        observe(task, ghostDataTask)
        return ghostDataTask!
    }

    open func data(_ request: URLRequest) throws -> GhostTask {
        guard let ghostRequest = request.ghostRequest else {
            throw ghostError(URLError(.badURL))
        }
        return data(ghostRequest)
    }

    open func data(_ url: URL, cachePolicy: GhostRequest.GhostCachePolicy? = nil, timeoutInterval: TimeInterval? = nil) -> GhostTask {
        return data(ghostRequest(url, cache: cachePolicy, timeout: timeoutInterval))
    }

    open func data(_ urlString: String, cachePolicy: GhostRequest.GhostCachePolicy? = nil, timeoutInterval: TimeInterval? = nil) throws -> GhostTask {
        guard let url = URL(string: urlString) else {
            throw ghostError(URLError(.badURL))
        }
        return data(url, cachePolicy: cachePolicy, timeoutInterval: timeoutInterval)
    }

}
