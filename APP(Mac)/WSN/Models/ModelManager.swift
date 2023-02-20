//
//  ModelManager.swift
//  ProjectII
//
//  Created by Azuby on 31/01/2023.
//

import UIKit
import Alamofire

class ModelManager {
    
    static let shared = ModelManager()

    private var server = "192.168.1.78:3000"
    
    private let decoder = JSONDecoder()
    private let storage = Storage()
    
    weak var req: DataRequest?
    
    func setServer(_ string: String) {
        server = string
    }
    
    func fetch(_ time: CGFloat = 5) {
        req?.cancel()
        
        if time < 4.8 {
            DispatchQueue.global(qos: .default).asyncAfter(deadline: .now() + 5 - time) {
                self.fetch()
            }
            return
        }
        DispatchQueue.global(qos: .default).async { [self] in
            let date = Date()
            
            let headers: HTTPHeaders = [
//                "Authorization": "Bearer \(jwt)",
                "Content-type": "application/json",
            ]
            
            req = AF.upload(("{\"password\": \"9797964a-2f5c-41c6-91c1-44aa68308631\"}").data(using: .utf8)!, to: "http://\(server)/espGet", headers: headers)
            req?.responseData { [self] res in
                guard let data = res.data,
                      let object = try? decoder.decode([String:[Feed]].self, from: data)
                else {
                    // Failed
                    print("Fetch failed in \(date.distance(to: Date()))s")
                    fetch(date.distance(to: Date()))
                    return
                }
                
                // Success
                
                storage.descriptObject(object)
                
                print("Fetch success in \(date.distance(to: Date()))s")
                fetch(date.distance(to: Date()))
            }
        }
    }
    
    /// WARNING: Do not run outside model
    func post(_ data: (number: Int, value: CGFloat)) {
        req?.cancel()

        let date = Date()
        
        let headers: HTTPHeaders = [
//                "Authorization": "Bearer \(jwt)",
            "Content-type": "application/json",
        ]
        
        req = AF.upload(("{\"password\": \"9797964a-2f5c-41c6-91c1-44aa68308631\", \"number\":\(data.number),\"value\":\(data.value),\"isSP\":true}").data(using: .utf8)!, to: "http://\(server)/espPost", headers: headers)

        req?.responseData { [self] res in
            guard let data = res.data,
                  let code = String(data: data, encoding: .utf8),
                  code != "0"
            else {
                // Failed
                print("Post failed in \(date.distance(to: Date()))s")
                post(data)
                return
            }

            // Success

            print("Post success in \(date.distance(to: Date()))s")
        }
    }
    
    func getStorage() -> Storage {
        return storage
    }
}

class Feed: Codable {
    var value: CGFloat
    var date: CGFloat
}
