//
//  TabBarVC.swift
//  GoFeds
//
//  Created by Novos on 21/04/20.
//  Copyright © 2020 Novos. All rights reserved.
//

import Foundation
import UIKit

class TabBarVC: UITabBarController {
    
}

extension UITabBar {
    override open func sizeThatFits(_ size: CGSize) -> CGSize {
        var sizeThatFits = super.sizeThatFits(size)
        sizeThatFits.height = 60
        
        if #available(iOS 11.0, *) {
            let window = UIApplication.shared.keyWindow
            let bottomPadding = window?.safeAreaInsets.bottom ?? 0.0
            sizeThatFits.height += bottomPadding
        }
        return sizeThatFits
    }
}
