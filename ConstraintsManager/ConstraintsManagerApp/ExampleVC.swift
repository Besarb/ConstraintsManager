//
//  ExampleVC.swift
//  ConstraintsManager
//
//  Created by Besarb Zeqiraj on 19.12.18.
//  Copyright © 2018 Besarb. All rights reserved.
//

import UIKit
import ConstraintsManager

class ExampleVC: UIViewController {

    var cm1 = ConstraintsManager()
    var cm2 = ConstraintsManager()
    
    let v1 = UIView()
    let v2 = UIView()
    let v3 = UIView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "CM Example"
        view.backgroundColor = .black
        
        v1.backgroundColor = .red
        v2.backgroundColor = .green
        v3.backgroundColor = .blue
        
        navigationItem.rightBarButtonItems = [
            UIBarButtonItem(title: "cm2", style: .plain, target: self, action: #selector(activateCm2)),
            UIBarButtonItem(title: "cm1", style: .plain, target: self, action: #selector(activateCm1))
        ]
        
        setupViews()
    }
}

private extension ExampleVC {
    
    func setupViews() {
        
        [v1, v2, v3].forEach {
            view.addSubview($0)
        }
        
        let margin: CGFloat = 10
        let size: CGFloat = 100
        
        let metrics = [
            "margin": margin,
            "size": size
        ]
        let views = [
            "v1": v1,
            "v2": v2,
            "v3": v3
        ]
        
        cm2 = ConstraintsManager(views: views)
        cm2 += "H:|-20-[v1]-20-|"
        cm2 += "H:|-20-[v2]-20-|"
        cm2 += "H:|-20-[v3]-20-|"
        cm2 += "V:|-200-[v1]-20-[v2(v1)]-20-[v3(v1)]-100-|"
        cm2.activate()
        
        cm1 = ConstraintsManager(views: views, metrics: metrics)
        cm1.add("H:|-margin-[v1(size)]")
        cm1 += "H:|-margin-[v2]-margin-|"
        cm1 += "V:[v1(size)]-margin-[v2(size)]"
        cm1.add(v1.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: margin))
        cm1.add(item: v3, attribute: .centerX, relatedBy: .equal, toItem: view, attribute: .centerX, multiplier: 1.0, constant: 0.0)
        cm1 += v3.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 1.0/2.0)
        cm1 += NSLayoutConstraint(item: v3, attribute: .top, relatedBy: .equal, toItem: v2, attribute: .bottom, multiplier: 1.0, constant: margin)
        cm1.add("V:[view(size)]", options: [], metrics: ["size": 200], views: ["view": v3])
    }
}

@objc
extension ExampleVC {
    
    func activateCm1() {
        view.setNeedsUpdateConstraints()
        UIView.animate(withDuration: 1.0) {
            self.cm2.deactivate()
            self.cm1.activate()
            self.view.layoutIfNeeded()
        }
        
    }
    
    func activateCm2() {
        view.setNeedsUpdateConstraints()
        UIView.animate(withDuration: 1.0) {
            self.cm1.deactivate()
            self.cm2.activate()
            self.view.layoutIfNeeded()
        }
        
    }
}
