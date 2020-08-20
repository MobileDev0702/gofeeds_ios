//
//  CustomButton.swift
//  POS-Native
//
//  Created by intersoft-admin on 28/04/18.
//  Copyright © 2018 intersoft-kansal. All rights reserved.
//

import UIKit
import IBAnimatable
import SkyFloatingLabelTextField

class CommonBtn: AnimatableButton
{
    var orignalTextSize: CGFloat?
    @IBInspectable
    public var localisedString: String = ""
    {
        didSet
        {
            
        }
    }
    
    override func awakeFromNib()
    {
        if UIDevice().userInterfaceIdiom == .phone
        {
            super.awakeFromNib()
            if orignalTextSize == nil
            {
                orignalTextSize = self.titleLabel?.font.pointSize
            }
            
            self.titleLabel?.font = UIFont.init(name: self.titleLabel?.font.familyName ?? "Helvetica", size: self.orignalTextSize! + Utils.screenSizeEnum())
        }
        if localisedString != ""
        {
            self.setTitle(localisedString.localize, for: .normal)
        }
    }
    
    override func layoutSubviews()
    {
        super.layoutSubviews()
        if UIDevice().userInterfaceIdiom == .phone
        {
            if orignalTextSize == nil
            {
                orignalTextSize = self.titleLabel?.font.pointSize
            }
            
            self.titleLabel?.font = UIFont.init(name: self.titleLabel?.font.familyName ?? "Helvetica", size: self.orignalTextSize! + Utils.screenSizeEnum())
        }
    }
}

class CommonLbl : AnimatableLabel
{
    var orignalTextSize: CGFloat?
    
    @IBInspectable
    public var localisedString: String = ""
    {
        didSet
        {
            
        }
    }
    
    override open var text: String? {
        didSet
        {
            if UIDevice().userInterfaceIdiom == .phone
            {
                if orignalTextSize == nil
                {
                    orignalTextSize = self.font.pointSize
                }
                
                self.font = UIFont.init(name: self.font.familyName, size: self.orignalTextSize! + Utils.screenSizeEnum())
            }
        }
    }
    
    override func awakeFromNib()
    {
        if UIDevice().userInterfaceIdiom == .phone
        {
            super.awakeFromNib()
            if orignalTextSize == nil
            {
                orignalTextSize = self.font.pointSize
            }
             self.font = UIFont.init(name: self.font.familyName, size: self.orignalTextSize! + Utils.screenSizeEnum())
        }
        
        if localisedString != ""
        {
            self.text = localisedString.localize
        }
    }
    
    override func layoutSubviews()
    {
        if UIDevice().userInterfaceIdiom == .phone
        {
            super.layoutSubviews()
            if orignalTextSize == nil
            {
                orignalTextSize = self.font.pointSize
            }
            
            self.font = UIFont.init(name: self.font.familyName, size: self.orignalTextSize! + Utils.screenSizeEnum())
        }
    }
}

class PaddedLabel: TextColorLbl
{
    override func drawText(in rect: CGRect)
    {
        let insets: UIEdgeInsets = UIEdgeInsets(top: 0.0, left: 0.0, bottom: 0.0, right: 10.0)
        super.drawText(in: rect.inset(by: insets))
    }
}

class PadAllLabel: TextColorLbl
{
    override func drawText(in rect: CGRect)
    {
        let insets: UIEdgeInsets = UIEdgeInsets(top: 4.0, left: 4.0, bottom: 4.0, right: 4.0)
        super.drawText(in: rect.inset(by: insets))
    }
}

class PadLabel: CommonLbl
{
    override func drawText(in rect: CGRect)
    {
        let insets: UIEdgeInsets = UIEdgeInsets(top: 0.0, left: 10.0, bottom: 0.0, right: 10.0)
        super.drawText(in: rect.inset(by: insets))
    }
}

class Pad5Label: CommonLbl
{
    override func drawText(in rect: CGRect)
    {
        let insets: UIEdgeInsets = UIEdgeInsets(top: 0.0, left: 5.0, bottom: 0.0, right: 5.0)
        super.drawText(in: rect.inset(by: insets))
    }
}

class CommonTxtSky: SkyFloatingLabelTextField
{
    var orignalTextSize: CGFloat?
    
    @IBInspectable
    public var localisedString: String = ""
    {
        didSet
        {
            
        }
    }
    
    override func awakeFromNib()
    {
        if UIDevice().userInterfaceIdiom == .phone
        {
            super.awakeFromNib()
            
            if orignalTextSize == nil
            {
                orignalTextSize = self.font?.pointSize
            }
            self.tintColor = .darkGray
            self.font = self.font?.withSize(self.orignalTextSize! + Utils.screenSizeEnum())
        }
        
        if localisedString != ""
        {
            self.placeholder = localisedString.localize
        }
    }
    
    override open var text: String? {
        didSet
        {
            if UIDevice().userInterfaceIdiom == .phone
            {
                if orignalTextSize == nil
                {
                    orignalTextSize = self.font?.pointSize
                }
                self.font = self.font?.withSize(self.orignalTextSize! + Utils.screenSizeEnum())
            }
        }
    }
    
    override func layoutSubviews()
    {
        super.layoutSubviews()
        if UIDevice().userInterfaceIdiom == .phone
        {
            if orignalTextSize == nil
            {
                orignalTextSize = self.font?.pointSize
            }
            self.font = self.font?.withSize(self.orignalTextSize! + Utils.screenSizeEnum())
        }
    }
}

class CommonTxtBrown: BrownSkyFloatingTextFld
{
    
}

class CommonTxt: AnimatableTextField
{
    var orignalTextSize: CGFloat?
    
    @IBInspectable
    public var localisedString: String = ""
    {
        didSet
        {
            
        }
    }
    
    override func awakeFromNib()
    {
        if UIDevice().userInterfaceIdiom == .phone
        {
            super.awakeFromNib()
            
            if orignalTextSize == nil
            {
                orignalTextSize = self.font?.pointSize
            }
            self.tintColor = .darkGray
            self.font = self.font?.withSize(self.orignalTextSize! + Utils.screenSizeEnum())
        }
        
        if localisedString != ""
        {
            self.placeholder = localisedString.localize
        }
        
    }
    
    override open var text: String? {
        didSet
        {
            if UIDevice().userInterfaceIdiom == .phone
            {
                if orignalTextSize == nil
                {
                    orignalTextSize = self.font?.pointSize
                }
                self.font = self.font?.withSize(self.orignalTextSize! + Utils.screenSizeEnum())
            }
        }
    }
    
    override func layoutSubviews()
    {
        super.layoutSubviews()
        if UIDevice().userInterfaceIdiom == .phone
        {
            if orignalTextSize == nil
            {
                orignalTextSize = self.font?.pointSize
            }
            self.font = self.font?.withSize(self.orignalTextSize! + Utils.screenSizeEnum())
        }
    }
}

class BottomBrownBorderTxtFld: CommonTxt
{
    override func layoutSubviews()
    {
        super.layoutSubviews()
        self.layer.borderColor = UIColor.accentColor().cgColor
    }
}

class BorderColorTxtFld: CommonTxt
{
    override func awakeFromNib()
    {
        super.awakeFromNib()
        self.textColor = UIColor.primaryColor()
    }
    
    override func layoutSubviews()
    {
        super.layoutSubviews()
        self.layer.borderColor = UIColor.primaryColor().cgColor
    }
}

class CommonTxtVw: AnimatableTextView
{
}

class BottomBrownBorderTxtVw: AnimatableTextView
{
    override func awakeFromNib()
    {
        super.awakeFromNib()
        self.borderColor = UIColor.accentColor()
    }
}

class CustomButton: CommonBtn
{
    override func awakeFromNib()
    {
        super.awakeFromNib()
        self.backgroundColor = UIColor.primaryColor()
    }
}

class CustomDarkNavButton: CommonBtn
{
    override func awakeFromNib()
    {
        super.awakeFromNib()
        self.backgroundColor = UIColor.primaryDarkColor()
    }
}

class CyanTextColorButton: CommonBtn
{
    override func awakeFromNib()
    {
        super.awakeFromNib()
        self.setTitleColor(UIColor.primaryDarkColor(), for: .normal)
    }
}

class BorderColorView: AnimatableView
{
    override func layoutSubviews()
    {
        self.layer.borderColor = UIColor.primaryDarkColor().cgColor
    }
}

class RightBarBtn: UIButton
{
    func setButton(_ image: UIImage?, _ title: String?) -> RightBarBtn
    {
        if image != nil
        {
            self.setImage(image?.withRenderingMode(.alwaysTemplate), for: .normal)
            self.imageView?.contentMode = .scaleAspectFit
        }
        else if title != nil
        {
            super.layoutSubviews()
            self.titleLabel?.text = title
            self.tintColor = UIColor.white
            self.titleLabel?.textAlignment = .center
            self.titleLabel?.font = UIFont.systemFont(ofSize: 13)
            self.titleLabel?.textColor = .white
        }
        
        return self
    }
}

class TintColorBtnImage: CommonBtn
{
    override func layoutSubviews()
    {
        super.layoutSubviews()
        
        self.imageView?.image = self.imageView?.image!.withRenderingMode(.alwaysTemplate)
        self.imageView?.tintColor = UIColor.primaryColor()
    }
}

class BackgroundColorView: AnimatableView
{
    override func awakeFromNib()
    {
        super.awakeFromNib()
        self.backgroundColor = UIColor.primaryDarkColor()
    }
}

class BackgroundLightColorView: AnimatableView
{
    override func awakeFromNib()
    {
        super.awakeFromNib()
        self.backgroundColor = UIColor.primaryColor()
    }
}

class BackgroundColorImgView: UIImageView
{
    override func awakeFromNib()
    {
        super.awakeFromNib()
        self.backgroundColor = UIColor.accentColor()
    }
}

class BackgroundColorTableView: UITableView
{
    override func awakeFromNib()
    {
        super.awakeFromNib()
        self.backgroundColor = UIColor.primaryDarkColor()
    }
}

class BackgroundColorTableViewCell: UITableViewCell
{
    override func awakeFromNib()
    {
        super.awakeFromNib()
        self.backgroundColor = UIColor.primaryDarkColor()
    }
}

class TextColorLbl: CommonLbl
{
    override func awakeFromNib()
    {
        super.awakeFromNib()
        self.textColor = UIColor.primaryDarkColor()
    }
}

class BackgroundColorLbl: CommonLbl
{
    override func awakeFromNib()
    {
        super.awakeFromNib()
        self.backgroundColor = UIColor.primaryDarkColor()
        self.textColor = UIColor.primaryDarkColor()
    }
}

class BackgroundLightColorLbl: CommonLbl
{
    override func awakeFromNib()
    {
        super.awakeFromNib()
        self.backgroundColor = UIColor.primaryColor()
        self.textColor = UIColor.primaryDarkColor()
    }
}

class LblBackgroundColor: CommonLbl
{
    override func awakeFromNib()
    {
        super.awakeFromNib()
        self.backgroundColor = UIColor.primaryDarkColor()
        self.textColor = UIColor.white
    }
}

class TextColorTxtFld: CommonTxt
{
    override func awakeFromNib()
    {
        super.awakeFromNib()
        self.textColor = UIColor.primaryDarkColor()
    }
}

class BgColorNavBar: UINavigationBar
{
    override func awakeFromNib()
    {
        super.awakeFromNib()
        self.barTintColor = UIColor.primaryDarkColor()
    }
}

class BrownBgColorLbl: CommonLbl
{
    override func awakeFromNib()
    {
        super.awakeFromNib()
        self.backgroundColor = UIColor.accentColor()
    }
}

class BrownTextColorLbl: CommonLbl
{
    override func awakeFromNib()
    {
        super.awakeFromNib()
        self.textColor = UIColor.accentColor()
    }
}

class BrownTextColorButton: CommonBtn
{
    override func awakeFromNib()
    {
        super.awakeFromNib()
        self.setTitleColor(UIColor.accentColor(), for: .normal)
    }
}

class PDBgColorButton: CommonBtn
{
    override func awakeFromNib()
    {
        super.awakeFromNib()
        self.titleLabel?.textColor = UIColor.white
        self.backgroundColor = UIColor.primaryDarkColor()
    }
}

class BrownBgColorButton: CommonBtn
{
    override func awakeFromNib()
    {
        super.awakeFromNib()
        self.titleLabel?.textColor = UIColor.white
        self.backgroundColor = UIColor.accentColor()
    }
}

class BrownBgColorView: UIView
{
    override func awakeFromNib()
    {
        super.awakeFromNib()
        self.backgroundColor = UIColor.primaryDarkColor()
    }
}

class LightRedLightBlueCyan: UIView
{
    override func awakeFromNib()
    {
        super.awakeFromNib()
        self.backgroundColor = UIColor.primaryColor()
    }
}

class ReservationViewColor: UIView
{
    override func awakeFromNib()
    {
        super.awakeFromNib()
        self.backgroundColor = UIColor.navigtnBarownColor1()
    }
}

class BrownYesslowBgColorView: UIView
{
    override func awakeFromNib()
    {
        super.awakeFromNib()
        self.backgroundColor = UIColor.accentColor()
    }
}

class BrownSkyFloatingTextFld: CommonTxtSky
{
    override func awakeFromNib()
    {
        super.awakeFromNib()
        self.lineColor = UIColor.accentColor()
        self.selectedLineColor = UIColor.accentColor()
        self.selectedTitleColor = UIColor.accentColor()
    }
}

class BrownGreySkyFloatingTxtFld: CommonTxtSky
{
    override func awakeFromNib()
    {
        super.awakeFromNib()
        
        self.selectedLineColor = UIColor.darkGray
        self.selectedTitleColor = UIColor.accentColor()
    }
}

class BrownTintColorImg: UIImageView
{
    override func layoutSubviews()
    {
        self.image = self.image!.withRenderingMode(.alwaysTemplate)
        self.tintColor = UIColor.accentColor()
    }
}

class PaddedTxtFld: BorderColorTxtFld
{
    var padding = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
    
    override func textRect(forBounds bounds: CGRect) -> CGRect
    {
        return bounds.inset(by: padding)
    }
    
    override func placeholderRect(forBounds bounds: CGRect) -> CGRect
    {
        return bounds.inset(by: padding)
    }
    
    override func editingRect(forBounds bounds: CGRect) -> CGRect
    {
        return bounds.inset(by: padding)
    }
    
    func needPadding(_ need:  Bool)
    {
        if need
        {
            self.padding = UIEdgeInsets(top: 0, left: (UIDevice().userInterfaceIdiom == .phone ? 20 : 24), bottom: 0, right: 0);
        }
        else
        {
            self.padding = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0);
        }
        
        self.setNeedsLayout()
    }
}


class CustomSwitch: UISwitch
{
    override func awakeFromNib()
    {
        super.awakeFromNib()
        
        self.onTintColor = UIColor.accentColor()
    }
}

class CustomSlider: AnimatableSlider
{
    func convertCIImageToCGImage(inputImage: CIImage) -> CGImage!
    {
        let context = CIContext(options: nil)
        return context.createCGImage(inputImage, from: inputImage.extent)
    }
    
    override func awakeFromNib()
    {
        super.awakeFromNib()
        
        self.maximumTrackTintColor = UIColor.lightAccentColor()
        self.minimumTrackTintColor = UIColor.accentColor()
        
        let img = UIImage.init(named: "slider_thumb")
        
        let rect = CGRect.init(x: 0, y: 0, width: (img?.size.width)!, height: (img?.size.height)!)
        UIGraphicsBeginImageContext(rect.size)
        let context = UIGraphicsGetCurrentContext()
        
        let ciImage = CIImage(image: img!)
        let cgimage = self.convertCIImageToCGImage(inputImage: ciImage!)
        context?.clip(to: rect, mask: cgimage!)
        context!.setFillColor(UIColor.accentColor().cgColor)
        context!.fill(rect)
        let img1 = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        self.setThumbImage(img1, for: .normal)
        
        //self.thumbTintColor = UIColor.accentColor()
    }
}
