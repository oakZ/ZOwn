//
//  OZUIFactory.swift
//  ZOwn
//
//  Created by oak on 2017/7/4.
//  Copyright © 2017年 oak. All rights reserved.
//

import UIKit

class OZUIFactory: NSObject {
    
    // MARK: - 各种Tag
    
    class func tag(text: String, fontSize: CGFloat, backgroundColor: UIColor) -> UIImage? {
        let image = self.tag(text: text, fontSize: fontSize, attributes: nil, textInset: nil, backgroundColor: backgroundColor, radius: nil)
        return image
    }
    
    class func tag(text: String, fontSize: CGFloat, textInset: UIEdgeInsets, backgroundColor: UIColor, radius: CGFloat) -> UIImage? {
        let image = self.tag(text: text, fontSize: fontSize, attributes: nil, textInset: textInset, backgroundColor: backgroundColor, radius: radius)
        return image
    }
    
    class func tag(text: String, fontSize: CGFloat, attributes: Dictionary<NSAttributedStringKey, Any>?, textInset: UIEdgeInsets?, backgroundColor: UIColor?, radius: CGFloat?) -> UIImage? {
        
        // default params
        let defaultAttributes = [NSAttributedStringKey.font : UIFont.systemFont(ofSize: fontSize), NSAttributedStringKey.foregroundColor : UIColor.white]
        let defaultBackgroundColor = UIColor.blue
        let defaultInset = UIEdgeInsetsMake(2, 3, 2, 3)
        
        var textAttributes = attributes ?? defaultAttributes
        textAttributes.updateValue(UIFont.systemFont(ofSize: fontSize), forKey: NSAttributedStringKey.font)
        let bgColor = backgroundColor ?? defaultBackgroundColor
        let inset = textInset ?? defaultInset
        
        // caculate the size
        let lineHeight = UIFont.systemFont(ofSize: fontSize).lineHeight
        var size = text.boundingRect(with: CGSize(width: CGFloat.greatestFiniteMagnitude, height: lineHeight), options: [.usesFontLeading, .usesLineFragmentOrigin, .usesDeviceMetrics], attributes: textAttributes, context: nil).size
        size = CGSize(width: ceil(size.width + inset.left + inset.right), height: ceil(lineHeight + inset.top + inset.bottom))
        
        // creat the UIImage
        UIGraphicsBeginImageContextWithOptions(size, false, 0)
        
        // background color
        bgColor.setFill()
        let rect = CGRect.init(origin: CGPoint.zero, size: size)
        
        if radius == nil {
            let path = UIBezierPath.init(rect: rect)
            path.fill()
        }else {
            let path = UIBezierPath.init(roundedRect: rect, cornerRadius: radius!)
            path.fill()
            
        }
        
        // draw text
        text.draw(at: CGPoint(x: inset.left, y: inset.top), withAttributes: textAttributes)
        
        let tag = UIGraphicsGetImageFromCurrentImageContext()
        
        UIGraphicsEndImageContext()
        
        return tag
    }

}
