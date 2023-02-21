//
//  SPPreview.swift
//  ProjectII
//
//  Created by Azuby on 06/02/2023.
//

import UIKit

// Chứa các bảng set ngưỡng
class SPPreview: UIViewPointSubview {

    @IBOutlet weak var SPList: UIStackViewForwardPointSubview!
    
    private var didLoad = false
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        commonInit()
    }
    @IBAction func b(_ sender: Any) {
        ModelManager.shared.getStorage().setSetPoint(of: 3, CGFloat.random(in: 0...100))
    }
    
    private func commonInit() {
        let nib = UINib(nibName: "SPPreview", bundle: nil)
        guard let view = nib.instantiate(withOwner: self, options: nil).first as? UIView else { return }
        
        view.translatesAutoresizingMaskIntoConstraints = false
        view.clipsToBounds = false
        addSubview(view)
        NSLayoutConstraint.activate([
            view.leadingAnchor.constraint(equalTo: leadingAnchor),
            view.trailingAnchor.constraint(equalTo: trailingAnchor),
            view.topAnchor.constraint(equalTo: topAnchor),
            view.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
    }
    
    override func draw(_ rect: CGRect) {
        super.draw(rect)
        
        if didLoad { return }
        didLoad = true
        
        for view in SPList.arrangedSubviews {
            view.removeFromSuperview()
        }
        
        for index in 0..<ModelManager.shared.getStorage().getCount() {
            let sp = SetPoint()
            sp.layer.cornerRadius = 12
            sp.layer.cornerCurve = .continuous
            sp.backgroundColor = UIColor(white: 0.1, alpha: 1)
            sp.clipsToBounds = true
            sp.restorationIdentifier = "\(index)"
            sp.translatesAutoresizingMaskIntoConstraints = false
            
            SPList.addArrangedSubview(sp)
            
            NSLayoutConstraint.activate([
                sp.heightAnchor.constraint(equalToConstant: 160)
            ])
        }
        
        layoutIfNeeded()
        
        NotificationCenter.default.addObserver(self, selector: #selector(touch), name: Notification.Name("stackview.hightlight."), object: nil)
    }
    @objc func touch(_ noti: Notification) {
        guard let index = noti.object as? Int else { return }
        
        isUserInteractionEnabled = index == 1
    }
}
