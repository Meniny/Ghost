//
//  GhostURLSession+Stream.swift
//  Ghost
//
//  Created by Elias Abel on 17/3/17.
//
//

#if !os(watchOS)
@available(iOS 9.0, macOS 10.11, *)
extension GhostURLSession {

    open func stream(_ service: NetService) -> GhostTask {
        let task = session.streamTask(with: service)
        let streamTask = ghostTask(task)
        observe(task, streamTask)
        return streamTask
    }

    open func stream(_ domain: String, type: String, name: String = "", port: Int32? = nil) -> GhostTask {
        guard let port = port else {
            return stream(NetService(domain: domain, type: type, name: name))
        }
        return stream(NetService(domain: domain, type: type, name: name, port: port))
    }

    open func stream(_ hostName: String, port: Int) -> GhostTask {
        let task = session.streamTask(withHostName: hostName, port: port)
        let ghostStreamTask = ghostTask(task)
        observe(task, ghostStreamTask)
        return ghostStreamTask
    }

}
#endif
