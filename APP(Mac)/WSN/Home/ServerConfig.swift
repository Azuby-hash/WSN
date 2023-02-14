//
//  ServerConfig.swift
//  WSN
//
//  Created by Azuby on 14/02/2023.
//

import UIKit

class ServerConfig: UITextField, UITextFieldDelegate {

    override func draw(_ rect: CGRect) {
        super.draw(rect)
        
        delegate = self
    }

    func textFieldDidChangeSelection(_ textField: UITextField) {
        ModelManager.shared.setServer(textField.text ?? "")
    }
}
