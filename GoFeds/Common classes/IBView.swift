//
//  IBView.swift
//  GoFeds
//
//  Created by Inderveer Singh on 10/06/20.
//  Copyright © 2020 Novos. All rights reserved.
//

import UIKit

class IBView: UIView {
    
    override init(frame: CGRect) {
      super.init(frame: frame)
      setupView()
    }
    
    //initWithCode to init view from xib or storyboard
    required init?(coder aDecoder: NSCoder) {
      super.init(coder: aDecoder)
      setupView()
        layer.cornerRadius = 12
    }
    
    //common func to init our view
    private func setupView() {
        self.addSoftShadow()
    }

}

extension UIView {
    func addSoftShadow(){
        self.layer.shadowColor = UIColor.black.cgColor
        self.layer.shadowOpacity = 0.1
        self.layer.shadowOffset = .zero
        self.layer.shadowRadius = 6
    }
}
