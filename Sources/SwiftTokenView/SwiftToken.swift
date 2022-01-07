//
//  SwiftToken.swift
//  
//
//  Created by Reshad Farid on 21/12/2021.
//

import UIKit

open class SwiftToken : UIControl {
    
    //MARK: - Public Properties
    //__________________________________________________________________________________
    //
    
    /// retuns title as description
    override open var description : String {
        get {
            return title
        }
    }
    
    /// default is ""
    open var title = ""
    
    /// default is nil. Any Custom object.
    open var object: AnyObject?
    
    /// default is false. If set to true, token can not be deleted
    open var sticky = false
    
    /// Token Title color
    open var tokenTextColor = UIColor(red: 255/255, green: 255/255, blue: 255/255, alpha: 1)
    
    /// Token background color
    open var tokenBackgroundColor = UIColor(red: 50/255, green: 50/255, blue: 255/255, alpha: 1)
    
    /// Token title color in selected state
    open var tokenTextHighlightedColor: UIColor?
    
    /// Token backgrould color in selected state
    open var tokenBackgroundHighlightedColor: UIColor?
    
    /// Token background color in selected state. It doesn't have effect if 'tokenBackgroundHighlightedColor' is set
    open var darkRatio: CGFloat = 0.75
    
    /// Token border width
    open var borderWidth: CGFloat = 0.0
    
    ///Token border color
    open var borderColor: UIColor = UIColor.black
    
    /// default is 200. Maximum width of token. After maximum limit is reached title is truncated at end with '...'
    fileprivate var _maxWidth: CGFloat? = 200
    open var maxWidth: CGFloat {
        get{
            return _maxWidth!
        }
        set (newWidth) {
            if (_maxWidth != newWidth) {
                _maxWidth = newWidth
                sizeToFit()
                setNeedsDisplay()
            }
        }
    }
    
    /// returns true if token is selected
    override open var isSelected: Bool {
        didSet (newValue) {
            setNeedsDisplay()
        }
    }
    
    //MARK: - Constructors
    //__________________________________________________________________________________
    //
    convenience required public init(coder aDecoder: NSCoder) {
        self.init(title: "")
    }
    
    convenience public init(title: String) {
        self.init(title: title, object: title as AnyObject?);
    }
    
    public init(title: String, object: AnyObject?) {
        self.title = title
        self.object = object
        super.init(frame: CGRect.zero)
        backgroundColor = UIColor.clear
    }
    
    //MARK: - Drawing code
    //__________________________________________________________________________________
    //
    override open func draw(_ rect: CGRect) {
        //// General Declarations
        let context = UIGraphicsGetCurrentContext()
        
        //// Rectangle Drawing
        
        // fill background
        let rectanglePath = UIBezierPath(roundedRect: rect, cornerRadius: 15)
        
        var textColor: UIColor
        var backgroundColor: UIColor
        
        if (isSelected) {
            if (tokenBackgroundHighlightedColor != nil) {
                backgroundColor = tokenBackgroundHighlightedColor!
            } else {
                backgroundColor = tokenBackgroundColor.darkendColor(darkRatio)
            }
            
            if (tokenTextHighlightedColor != nil) {
                textColor = tokenTextHighlightedColor!
            } else {
                textColor = tokenTextColor
            }
            
        } else {
            backgroundColor = tokenBackgroundColor
            textColor = tokenTextColor
        }
        
        backgroundColor.setFill()
        rectanglePath.fill()
        
        var paddingX: CGFloat = 0.0
        var font = UIFont.systemFont(ofSize: 14)
        var tokenField: SwiftTokenField? {
            return superview! as? SwiftTokenField
        }
        if ((tokenField) != nil) {
            paddingX = tokenField!.paddingX()!
            font = tokenField!.tokenFont()!
        }
        
        // Text
        let rectangleTextContent = title
        let rectangleStyle = NSMutableParagraphStyle.default.mutableCopy() as! NSMutableParagraphStyle
        rectangleStyle.lineBreakMode = NSLineBreakMode.byTruncatingTail
        rectangleStyle.alignment = NSTextAlignment.center
        let rectangleFontAttributes = [NSAttributedString.Key.font: font, NSAttributedString.Key.foregroundColor: textColor, NSAttributedString.Key.paragraphStyle: rectangleStyle] as [NSAttributedString.Key : Any]
        
        let maxDrawableHeight = max(rect.height , font.lineHeight)
        let textHeight: CGFloat = SwiftTokenUtils.getRect(rectangleTextContent as NSString, width: rect.width, height: maxDrawableHeight , font: font).size.height
        
        let textRect = CGRect(x: rect.minX + paddingX, y: rect.minY + (maxDrawableHeight - textHeight) / 2, width: min(maxWidth, rect.width) - (paddingX*2), height: maxDrawableHeight)
        
        rectangleTextContent.draw(in: textRect, withAttributes: rectangleFontAttributes)
        
        #if swift(>=2.3)
        context!.saveGState()
        context!.clip(to: rect)
        context!.restoreGState()
        #else
        context.saveGState()
        context.clip(to: rect)
        context.restoreGState()
        #endif
        
        // Border
        if (borderWidth > 0.0 && borderColor != UIColor.clear) {
            borderColor.setStroke()
            rectanglePath.lineWidth = borderWidth
            rectanglePath.stroke()
        }
    }
}
