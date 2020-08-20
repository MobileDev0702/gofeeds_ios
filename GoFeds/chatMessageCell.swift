//
//  chatMessageCell.swift
//  GoFeds
//
//  Created by Inderveer Singh on 09/06/20.
//  Copyright © 2020 Novos. All rights reserved.
//

import UIKit

class chatMessageCell: UICollectionViewCell {
    
    let bubbleView : UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(red: 0/255, green: 137/255, blue: 249/255, alpha: 1.0)
        view.translatesAutoresizingMaskIntoConstraints = false
        view.layer.cornerRadius = 16
        view.layer.masksToBounds = true 
        return view
    }()
    
    let textView: UILabel = {
        let tv = UILabel()
        tv.text = "Sample Text"
        tv.font = UIFont.systemFont(ofSize: 16)
        tv.textColor = .white
        tv.backgroundColor = .clear
        tv.translatesAutoresizingMaskIntoConstraints = false
        
        return tv
    }()
    
    var bubbleWidthAnchor : NSLayoutConstraint?
    var bubbleViewRightAnchor : NSLayoutConstraint?
    var bubbleViewLeftAnchor : NSLayoutConstraint?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
       // backgroundColor = .red
        
        addSubview(bubbleView)
        addSubview(textView)
        
        
        bubbleViewRightAnchor = bubbleView.rightAnchor.constraint(equalTo: self.rightAnchor,constant: -8 )
        bubbleViewRightAnchor?.isActive = true
        
        bubbleViewLeftAnchor = bubbleView.leftAnchor.constraint(equalTo: self.leftAnchor,constant: 8)
        //bubbleView.rightAnchor.constraint(equalTo: self.rightAnchor,constant: -8 ) .isActive = true
        bubbleView.topAnchor.constraint(equalTo: self.topAnchor).isActive = true
        bubbleWidthAnchor = bubbleView.widthAnchor.constraint(equalToConstant: 200)
        bubbleWidthAnchor?.isActive = true
        //bubbleView.widthAnchor.constraint(equalToConstant: 200) .isActive = true
        bubbleView.heightAnchor.constraint(equalTo: self.heightAnchor).isActive = true
        
        //
        textView.leftAnchor.constraint(equalTo: bubbleView.leftAnchor, constant: 8) .isActive = true
        textView.topAnchor.constraint(equalTo: self.topAnchor).isActive = true
        textView.rightAnchor.constraint(equalTo: bubbleView.rightAnchor).isActive = true
       // textView.widthAnchor.constraint(equalToConstant: 200) .isActive = true
        textView.heightAnchor.constraint(equalTo: self.heightAnchor).isActive = true
               
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not be elected")
    }
}
