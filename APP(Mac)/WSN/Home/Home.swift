//
//  ViewController.swift
//  WSN
//
//  Created by Azuby on 08/02/2023.
//

import UIKit

extension CALayer {
    // Border view có thể gán bên ngoài storyboard
    open override func setValue(_ value: Any?, forKey key: String) {
        guard key == "borderIBColor", let color = value as? UIColor else {
            super.setValue(value, forKey: key)
            return
        }
        
        self.borderColor = color.cgColor
    }
}

class Home: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    // Xuất file excel
    @IBAction func exportExcel(_ button: UIButton) {
        let exporter = ExportXlsxService.init()
        exporter.export()

        let url = NSURL.fileURL(withPath: "\(exporter.filePath())/\(exporter.filename)")
        
        // Bật popup lưu file
        let ac = UIActivityViewController(activityItems: [url], applicationActivities: nil)
        ac.popoverPresentationController?.sourceView = button
        ac.popoverPresentationController?.sourceRect = button.bounds
        ac.completionWithItemsHandler = { _, success, _, _ in
            DispatchQueue.main.async{ self.saveImageFinish(success) }
        }
        
        present(ac, animated: true)
    }
    
    // Alert hoàn thành lưu file
    func saveImageFinish(_ success: Bool) {
        let alert = UIAlertController(title: success ? "Saved" : "Error",
                                      message: success ? "Excel is exported!" : "Error export!",
                                      preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK, got it", style: .default) { _ in })
        present(alert, animated: true)
    }
}

//AF.request("http://172.20.10.4:3000/espGet?password=9797964a-2f5c-41c6-91c1-44aa68308631&number=1").response { [self] res in
//    if let data = res.data,
//       let string = String(data: data, encoding: .utf8) {
//        esp1.text = string
//    }
//}
