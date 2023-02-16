//
//  ViewController.swift
//  WSN
//
//  Created by Azuby on 08/02/2023.
//

import UIKit

extension CALayer {
    open override func setValue(_ value: Any?, forKey key: String) {
        guard key == "borderIBColor", let color = value as? UIColor else {
            super.setValue(value, forKey: key)
            return
        }
        
        self.borderColor = color.cgColor
    }
}

class Home: UIViewController {
    
    private let path: URL = {
        guard let path = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first?.appendingPathComponent("data.xml")
        else { return URL(fileURLWithPath: ".") }

        return path
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    @IBAction func exportExcel(_ sender: Any) {
        for temp in ModelManager.shared.getStorage().getAllStorage() {
            
        }
    }
}

//AF.request("http://172.20.10.4:3000/espGet?password=9797964a-2f5c-41c6-91c1-44aa68308631&number=1").response { [self] res in
//    if let data = res.data,
//       let string = String(data: data, encoding: .utf8) {
//        esp1.text = string
//    }
//}
