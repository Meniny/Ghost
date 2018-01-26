//
//  ViewController.swift
//  Sample
//
//  Created by 李二狗 on 2018/1/24.
//  Copyright © 2018年 Meniny Lab. All rights reserved.
//

import UIKit
import Ghost

enum SampleType: String {
    case async  = "Asynchronous"
    case sync   = "Synchronous"
    case decode = "Decode"
    case hunterAsync = "GhostHunter-Asynchronous"
    
    var selector: Selector {
        switch self {
        case .async:
            return #selector(ViewController.sample_async)
        case .sync:
            return #selector(ViewController.sample_sync)
        case .decode:
            return #selector(ViewController.sample_decode)
        case .hunterAsync:
            return #selector(ViewController.sample_gh_async)
        }
    }
    
    static let all: [SampleType] = [.async, .sync, .decode, .hunterAsync]
}

class ViewController: UITableViewController {

    let ghost: Ghost = GhostURLSession.shared
    let url = "https://meniny.cn/api/v2/about.json"
    lazy var request: GhostRequest = {
        let r = GhostRequest.init(self.url)
        return r!
    }()
    
    let cells: [SampleType] = SampleType.all
    
    let label = UILabel.init(frame: CGRect.init(x: 0, y: 0, width: 100, height: 20))
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.tableFooterView = UIView.init()
        self.tableView.register(UITableViewCell.self, forCellReuseIdentifier: "Cell")
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell")
        let data = self.cells[indexPath.row]
        cell?.textLabel?.text = data.rawValue
        return cell!
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.cells.count
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 50
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let data = self.cells[indexPath.row]
        self.perform(data.selector)
        self.tableView.deselectRow(at: indexPath, animated: true)
    }
    
    @objc
    func sample_async() {
        
        let controller = UIAlertController.init(title: "URL", message: "Enter the url", preferredStyle: .alert)
        controller.addTextField { (text) in
            text.clearButtonMode = .whileEditing
            text.placeholder = "URL"
            text.text = self.url
        }
        controller.addAction(UIAlertAction.init(title: "Go", style: .default, handler: { (_) in
            if let u = controller.textFields?.first?.text {
                if !u.isEmpty {
                    self.async(url: u)
                }
            }
        }))
        controller.addAction(UIAlertAction.init(title: "Cancel", style: .cancel, handler: nil))
        self.present(controller, animated: true, completion: nil)
    }
    
    func async(url u: String) {
        if let r = GhostRequest.init(u) {
            // Asynchronous
            ghost.data(request).async { (response, error) in
                do {
                    if let object: [AnyHashable: Any] = try response?.object() {
                        self.display("Asynchronous: \(object)")
                    } else if let error = error {
                        self.display("Asynchronous: Ghost error: \(error)")
                    }
                } catch {
                    self.display("Asynchronous: Parse error: \(error.localizedDescription)")
                }
            }
        }
    }
    
    @objc
    func sample_sync() {
        // Synchronous
        do {
            let date = Date()
            let object: [AnyHashable: Any] = try ghost.data(request).sync().object()
            self.display("Synchronous: \(object)\n Time: \(Date().timeIntervalSince(date))")
        } catch {
            self.display("Synchronous: Error: \(error)")
        }
        
    }
    
    @objc
    func sample_decode() {
        // Decode
        ghost.data(request).async { (response, error) in
            do {
                if let result: Response = try response?.decode() {
                    self.display(result.about.joined(separator: "\n------\n"))
                } else if let error = error {
                    self.display("Decode: Ghost error: \(error)")
                }
            } catch {
                self.display("Decode: Parse error: \(error)")
            }
        }
    }
    
    @objc func sample_gh_async() {
        let u = URL.init(string: self.url)!
        
        do {
            try GhostHunter.async(.GET, url: u, parameters: nil, headers: nil, progress: { (pregress) in
                print(pregress)
            }, completion: { (response, error) in
                do {
                    if let result: Response = try response?.decode() {
                        self.display(result.about.joined(separator: "\n------\n"))
                    } else if let error = error {
                        self.display("NightWatch Asynchronous: Ghost error: \(error)")
                    }
                } catch {
                    self.display("NightWatch: Parse error: \(error)")
                }
            })
        } catch {
            self.display("NightWatch: Request error: \(error)")
        }
    }

    func display(_ text: String, function: String = #function) {
        DispatchQueue.main.async {
            let next = DisplayViewController.init(nibName: "DisplayViewController", bundle: nil)
            next.text = text
            next.title = function
            self.navigationController?.show(next, sender: self)
            print(text)
        }
    }
}

