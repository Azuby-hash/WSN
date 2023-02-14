//
//  ChartPreview.swift
//  ProjectII
//
//  Created by Azuby on 01/02/2023.
//

import UIKit

class ChartPreview: UIViewPointSubview {
    
    @IBOutlet weak var chartList: UIStackViewForwardPointSubview!
    
    @IBOutlet weak var tableList: UIStackViewForwardPointSubview!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        commonInit()
    }
    
    private func commonInit() {
        let nib = UINib(nibName: "ChartPreview", bundle: nil)
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
    
    private var didLoad = false
    
    override func draw(_ rect: CGRect) {
        super.draw(rect)
        
        if didLoad { return }
        didLoad = true
        
        for view in chartList.arrangedSubviews {
            view.removeFromSuperview()
        }
        for view in tableList.arrangedSubviews {
            view.removeFromSuperview()
        }
        
        for index in 0..<ModelManager.shared.getStorage().getCount() {
            let chart = Chart()
//            chart.isHidden = true
            chart.layer.cornerRadius = 12
            chart.layer.cornerCurve = .continuous
            chart.backgroundColor = UIColor(white: 0.1, alpha: 1)
            chart.clipsToBounds = true
            chart.restorationIdentifier = "\(index)"
            chart.translatesAutoresizingMaskIntoConstraints = false
            
            chartList.addArrangedSubview(chart)
            
            NSLayoutConstraint.activate([
                chart.heightAnchor.constraint(equalToConstant: 250)
            ])
            
            let table = Table()
//            table.isHidden = true
            table.layer.cornerRadius = 12
            table.layer.cornerCurve = .continuous
            table.backgroundColor = UIColor(white: 0.1, alpha: 1)
            table.clipsToBounds = true
            table.restorationIdentifier = "\(index)"
            table.translatesAutoresizingMaskIntoConstraints = false
            
            tableList.addArrangedSubview(table)
            
            NSLayoutConstraint.activate([
                table.heightAnchor.constraint(equalToConstant: 250)
            ])
        }
        
        layoutIfNeeded()
        NotificationCenter.default.addObserver(self, selector: #selector(touch), name: Notification.Name("stackview.hightlight."), object: nil)
    }
    @objc func touch(_ noti: Notification) {
        guard let index = noti.object as? Int else { return }
        
        isUserInteractionEnabled = index == 0
    }
}
