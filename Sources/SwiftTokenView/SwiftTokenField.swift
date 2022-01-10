//
//  SwiftTokenField.swift
//  
//
//  Created by Reshad Farid on 21/12/2021.
//

import UIKit

let SwiftTokenTextEmpty = "\u{200B}"

class SwiftTokenUtils : NSObject {
    
    class func getRect(_ str: NSString, width: CGFloat, height: CGFloat, font: UIFont) -> CGRect {
        let rectangleStyle = NSMutableParagraphStyle.default.mutableCopy() as! NSMutableParagraphStyle
        rectangleStyle.alignment = NSTextAlignment.center
        let rectangleFontAttributes = [NSAttributedString.Key.font: font, NSAttributedString.Key.paragraphStyle: rectangleStyle]
        return str.boundingRect(with: CGSize(width: width, height: height), options: NSStringDrawingOptions.usesLineFragmentOrigin, attributes: rectangleFontAttributes, context: nil)
    }
    
    class func getRect(_ str: NSString, width: CGFloat, font: UIFont) -> CGRect {
        let rectangleStyle = NSMutableParagraphStyle.default.mutableCopy() as! NSMutableParagraphStyle
        rectangleStyle.alignment = NSTextAlignment.center
        let rectangleFontAttributes = [NSAttributedString.Key.font: font, NSAttributedString.Key.paragraphStyle: rectangleStyle]
        return str.boundingRect(with: CGSize(width: width, height: CGFloat(MAXFLOAT)), options: NSStringDrawingOptions.usesLineFragmentOrigin, attributes: rectangleFontAttributes, context: nil)
    }
    
    class func widthOfString(_ str: String, font: UIFont) -> CGFloat {
        let attrs = [NSAttributedString.Key.font: font]
        let attributedString = NSMutableAttributedString(string:str, attributes:attrs)
        return attributedString.size().width
    }
    
}

extension UIColor {
    func darkendColor(_ darkRatio: CGFloat) -> UIColor {
        var h: CGFloat = 0.0, s: CGFloat = 0.0, b: CGFloat = 0.0, a: CGFloat = 0.0
        if (getHue(&h, saturation: &s, brightness: &b, alpha: &a)) {
            return UIColor(hue: h, saturation: s, brightness: b*darkRatio, alpha: a)
        } else {
            return self
        }
    }
}


extension String {
    subscript(value: PartialRangeUpTo<Int>) -> Substring {
        get {
            return self[..<index(startIndex, offsetBy: value.upperBound)]
        }
    }
    
    subscript(value: PartialRangeThrough<Int>) -> Substring {
        get {
            return self[...index(startIndex, offsetBy: value.upperBound)]
        }
    }
    
    subscript(value: PartialRangeFrom<Int>) -> Substring {
        get {
            return self[index(startIndex, offsetBy: value.lowerBound)...]
        }
    }
}

enum SwiftTokenFieldState {
    case opened
    case closed
}

@objc protocol SwiftTokenFieldDelegate : UITextFieldDelegate {
    @objc optional func tokenFieldDidSelectToken(_ token: SwiftToken)
    @objc optional func tokenFieldDidBeginEditing(_ tokenField: SwiftTokenField)
    @objc optional func tokenFieldDidEndEditing(_ tokenField: SwiftTokenField)
}

@objc public enum SwiftTokenTextFieldScrollDirection: Int {
    case vertical
    case horizontal
}

open class SwiftTokenField: UITextField {
    
    // MARK: - Private Properties
    fileprivate var _cursorColor: UIColor = UIColor.gray {
        willSet {
            tintColor = newValue
        }
    }
    fileprivate var _setupCompleted: Bool = false
    fileprivate var _selfFrame: CGRect?
    fileprivate var _caretPoint: CGPoint?
    fileprivate var _placeholderValue: String?
    fileprivate var _placeholderLabel: UILabel?
    fileprivate var _state: SwiftTokenFieldState = .opened
    fileprivate var _minWidthForInput: CGFloat = 50.0
    fileprivate var _separatorText: String?
    fileprivate var _font: UIFont?
    fileprivate var _paddingX: CGFloat?
    fileprivate var _paddingY: CGFloat?
    fileprivate var _marginX: CGFloat?
    fileprivate var _marginY: CGFloat?
    fileprivate var _bufferX: CGFloat?
    fileprivate var _removesTokensOnEndEditing = true
    fileprivate var _scrollView = UIScrollView(frame: .zero)
    fileprivate var _scrollPoint = CGPoint.zero
    fileprivate var _direction: SwiftTokenTextFieldScrollDirection = .vertical {
        didSet {
            if (oldValue != _direction) {
                updateLayout()
            }
        }
    }
    fileprivate var _descriptionText: String = "selections" {
        didSet {
            _updateText()
        }
    }
    
    // MARK: - Public Properties
    
    /// default is grayColor()
    var promptTextColor: UIColor = UIColor.gray
    
    /// default is grayColor()
    var placeHolderColor: UIColor = UIColor.gray
    
    /// default is 120.0. After maximum limit is reached, tokens starts scrolling vertically
    var maximumHeight: CGFloat = 120.0
    
    /// default is nil
    override open var placeholder: String? {
        get {
            return _placeholderValue
        }
        set {
            super.placeholder = newValue
            if (newValue == nil) {
                return
            }
            _placeholderValue = newValue
        }
    }
    
    weak var parentView: SwiftTokenTextField? {
        willSet (tokenView) {
            if (tokenView != nil) {
                _cursorColor = tokenView!.cursorColor
                _paddingX = tokenView!.paddingX
                _paddingY = tokenView!.paddingY
                _marginX = tokenView!.marginX
                _marginY = tokenView!.marginY
                _bufferX = tokenView!.bufferX
                _direction = tokenView!.direction
                _font = tokenView!.font
                if (_font != nil) {
                    font = _font
                }
                _minWidthForInput = tokenView!.minWidthForInput
                _separatorText = tokenView!.separatorText
                _removesTokensOnEndEditing = tokenView!.removesTokensOnEndEditing
                _descriptionText = tokenView!.descriptionText
                placeHolderColor = tokenView!.placeholderColor
                promptTextColor = tokenView!.promptColor
                _setPromptText(tokenView!.promptText)
                
                if (_setupCompleted) {
                    updateLayout()
                }
            }
        }
    }
    
    weak var tokenFieldDelegate: SwiftTokenFieldDelegate? {
        didSet {
            delegate = tokenFieldDelegate
        }
    }
    
    /// returns Array of tokens
    var tokens = [SwiftToken]()
    
    /// returns selected KSToken object
    var selectedToken: SwiftToken?
    
    // MARK: - Constructors
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        _setupTokenField()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        _setupTokenField()
    }
    
    
    // MARK: - Methods
    
    // MARK: - Setup
    fileprivate func _setupTokenField() {
        text = ""
        autocorrectionType = UITextAutocorrectionType.no
        autocapitalizationType = UITextAutocapitalizationType.words
        contentVerticalAlignment = UIControl.ContentVerticalAlignment.top
        returnKeyType = UIReturnKeyType.done
        text = SwiftTokenTextEmpty
        backgroundColor = UIColor.white
        clipsToBounds = true
        _state = .closed
        
        _setScrollRect()
        _scrollView.backgroundColor = UIColor.clear
        _scrollView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        let gestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(UIResponder.becomeFirstResponder))
        gestureRecognizer.cancelsTouchesInView = false
        _scrollView.addGestureRecognizer(gestureRecognizer)
        _scrollView.delegate = self
        addSubview(_scrollView)
        
        addTarget(self, action: #selector(SwiftTokenField.tokenFieldTextDidChange(_:)), for: UIControl.Event.editingChanged)
    }
    
    fileprivate func _setScrollRect() {
        let buffer:CGFloat = _bufferX ?? 0.0;
        let width = frame.width - _leftViewRect().width
        let height = frame.height
        
        _scrollView.frame = CGRect(x: _leftViewRect().width + buffer, y: 0, width: width, height: height)
    }
    
    override open func draw(_ rect: CGRect) {
        if (!_setupCompleted) {
            _selfFrame = rect
        }
        _setupCompleted = true
        _updateText()
        
        // Fix the bug which doesn't update the UI when _selfFrame is not set.
        
        if (tokens.count > 0) {
            updateLayout()
        }
    }
    
    // MARK: - Add Token
    /**
     Create and add new token
     
     - parameter title: String value
     
     - returns: KSToken object
     */
    func addTokenWithTitle(_ title: String) -> SwiftToken? {
        return addTokenWithTitle(title, tokenObject: nil)
    }
    
    /**
     Create and add new token with custom object
     
     - parameter title:       String value
     - parameter tokenObject: Any custom object
     
     - returns: KSToken object
     */
    func addTokenWithTitle(_ title: String, tokenObject: AnyObject?) -> SwiftToken? {
        let token = SwiftToken(title: title, object: tokenObject)
        return addToken(token)
    }
    
    /**
     Add new token
     
     - parameter token: KSToken object
     
     - returns: KSToken object
     */
    func addToken(_ token: SwiftToken) -> SwiftToken? {
        if (token.title.count == 0) {
            token.title = "Untitled"
        }
        
        if (!tokens.contains(token)) {
            token.addTarget(self, action: #selector(SwiftTokenField.tokenTouchDown(_:)), for: .touchDown)
            token.addTarget(self, action: #selector(SwiftTokenField.tokenTouchUpInside(_:)), for: .touchUpInside)
            tokens.append(token)
            _insertToken(token)
        }
        
        return token
    }
    
    fileprivate func _insertToken(_ token: SwiftToken, shouldLayout: Bool = true) {
        _scrollView.addSubview(token)
        _scrollView.bringSubviewToFront(token)
        token.setNeedsDisplay()
        if shouldLayout == true {
            updateLayout()
        }
    }
    
    //MARK: - Delete Token
    /*
     **************************** Delete Token ****************************
     */
    
    /**
     Deletes a token from view
     
     - parameter token: KSToken object
     */
    func deleteToken(_ token: SwiftToken) {
        removeToken(token)
    }
    
    /**
     Deletes a token from view, if any token is found for custom object
     
     - parameter object: Custom object
     */
    func deleteTokenWithObject(_ object: AnyObject?) {
        if object == nil {return}
        for token in tokens {
            if (token.object!.isEqual(object)) {
                removeToken(token)
                break
            }
        }
    }
    
    /**
     Deletes all tokens from view
     */
    func forceDeleteAllTokens() {
        tokens.removeAll(keepingCapacity: false)
        for token in tokens {
            removeToken(token, removingAll: true)
        }
        updateLayout()
    }
    
    /**
     Deletes token from view
     
     - parameter token:       KSToken object
     - parameter removingAll: A boolean to describe if removingAll tokens
     */
    func removeToken(_ token: SwiftToken, removingAll: Bool = false) {
        if token.isEqual(selectedToken) {
            deselectSelectedToken()
        }
        token.removeFromSuperview()
        
        let index = tokens.firstIndex(of: token)
        if (index != nil) {
            tokens.remove(at: index!)
        }
        if (!removingAll) {
            updateLayout()
        }
    }
    
    
    //MARK: - Layout
    /*
     **************************** Layout ****************************
     */
    
    /**
     Untokenzies the layout
     */
    func untokenize() {
        if (!_removesTokensOnEndEditing) {
            return
        }
        _state = .closed
        for subview in _scrollView.subviews {
            if subview is SwiftToken {
                subview.removeFromSuperview()
            }
        }
        updateLayout()
    }
    
    /**
     Tokenizes the layout
     */
    func tokenize() {
        _state = .opened
        for token: SwiftToken in tokens {
            _insertToken(token, shouldLayout: false)
        }
        updateLayout()
    }
    
    /**
     Updates the tokenView layout and calls delegate methods
     */
    func updateLayout(_ shouldUpdateText: Bool = true) {
        if (parentView == nil) {
            return
        }
        
        _caretPoint = _layoutTokens()
        deselectSelectedToken()
        
        if (shouldUpdateText) {
            _updateText()
        }
        
        if _caretPoint != .zero {
            let tokensMaxY = max(_caretPoint!.y, _selfFrame!.height)
            
            if (frame.size.height != tokensMaxY) {
                // TODO
                // tokenFieldDelegate?.tokenFieldShouldChangeHeight(tokensMaxY)
            }
        }
    }
    
    /**
     Layout tokens
     
     - returns: CGPoint maximum position values
     */
    fileprivate func _layoutTokens() -> CGPoint {
        if (_selfFrame == nil) {
            return .zero
        }
        
        if (_state == .closed) {
            return CGPoint(x: _marginX! + _bufferX!, y: _selfFrame!.size.height)
        }
        
        if (_direction == .horizontal) {
            return _layoutTokensHorizontally()
        }
        
        var lineNumber = 1
        let leftMargin = _leftViewRect().width
        let rightMargin = _rightViewRect().width
        let tokenHeight = _font!.lineHeight + _paddingY!;
        
        var tokenPosition = CGPoint(x: _marginX!, y: _marginY!)
        
        for token: SwiftToken in tokens {
            let width = SwiftTokenUtils.getRect(token.title as NSString, width: bounds.size.width, font: _font!).size.width + ceil(_paddingX!*2+1)
            let tokenWidth = min(width, token.maxWidth)
            
            // Add token at specific position
            if ((token.superview) != nil) {
                if (tokenPosition.x + tokenWidth + _marginX! + leftMargin > bounds.size.width - rightMargin) {
                    lineNumber += 1
                    tokenPosition.x = _marginX!
                    tokenPosition.y += (tokenHeight + _marginY!);
                }
                
                token.frame = CGRect(x: tokenPosition.x, y: tokenPosition.y, width: tokenWidth, height: tokenHeight)
                tokenPosition.x += tokenWidth + _marginX!;
            }
        }
        
        // check if next token can be added in same line or new line
        if ((bounds.size.width) - (tokenPosition.x + _marginX!) - leftMargin < _minWidthForInput) {
            lineNumber += 1
            tokenPosition.x = _marginX!
            tokenPosition.y += (tokenHeight + _marginY!);
        }
        
        var positionY = (lineNumber == 1 && tokens.count == 0) ? _selfFrame!.size.height: (tokenPosition.y + tokenHeight + _marginY!)
        _scrollView.contentSize = CGSize(width: _scrollView.frame.width, height: positionY)
        if (positionY > maximumHeight) {
            positionY = maximumHeight
        }
        
        _scrollView.frame.size = CGSize(width: _scrollView.frame.width, height: positionY)
        scrollViewScrollToEnd()
        
        return CGPoint(x: tokenPosition.x + leftMargin, y: positionY)
    }
    
    
    /**
     Layout tokens horizontally
     
     - returns: CGPoint maximum position values
     */
    fileprivate func _layoutTokensHorizontally() -> CGPoint {
        let leftMargin = _leftViewRect().width
        let tokenHeight = _font!.lineHeight + _paddingY!;
        
        var tokenPosition = CGPoint(x: _marginX!, y: _marginY!)
        
        for token: SwiftToken in tokens {
            let width = SwiftTokenUtils.getRect(token.title as NSString, width: bounds.size.width, font: _font!).size.width + ceil(_paddingX!*2+1)
            let tokenWidth = min(width, token.maxWidth)
            
            if ((token.superview) != nil) {
                token.frame = CGRect(x: tokenPosition.x, y: tokenPosition.y, width: tokenWidth, height: tokenHeight)
                tokenPosition.x += tokenWidth + _marginX!;
            }
        }
        
        let offsetWidth = ((tokenPosition.x + _marginX! + _leftViewRect().width) > (frame.width - _minWidthForInput)) ? _minWidthForInput : 0
        _scrollView.contentSize = CGSize(width: max(_scrollView.frame.width, tokenPosition.x + offsetWidth), height: frame.height)
        scrollViewScrollToEnd()
        
        return CGPoint(x: min(tokenPosition.x + leftMargin, frame.width - _minWidthForInput), y: frame.height)
    }
    
    /**
     Scroll the tokens to end
     */
    func scrollViewScrollToEnd() {
        var bottomOffset: CGPoint
        switch _direction {
            case .vertical:
                bottomOffset = CGPoint(x: 0, y: _scrollView.contentSize.height - _scrollView.bounds.height)
            case .horizontal:
                bottomOffset = CGPoint(x: _scrollView.contentSize.width - _scrollView.bounds.width, y: 0)
        }
        _scrollView.setContentOffset(bottomOffset, animated: true)
    }
    
    //MARK: - Text Rect
    /*
     **************************** Text Rect ****************************
     */
    
    fileprivate func _textRectWithBounds(_ bounds: CGRect) -> CGRect {
        if (!_setupCompleted) {return .zero}
        
        if (tokens.count == 0 || _caretPoint == nil) {
            return CGRect(x: _leftViewRect().width + _marginX! + _bufferX!, y: _leftViewRect().origin.y, width: bounds.size.width-5, height: bounds.size.height)
        }
        
        if (tokens.count != 0 && _state == .closed) {
            return CGRect(x: _leftViewRect().maxX + _marginX! + _bufferX!, y: _leftViewRect().origin.y, width: (frame.size.width - _caretPoint!.x - _marginX!), height: bounds.size.height)
        }
        
        return CGRect(x: _caretPoint!.x, y: floor((_caretPoint!.y - font!.lineHeight - (_marginY!))), width: (frame.size.width - _caretPoint!.x - _marginX!), height: bounds.size.height)
    }
    
    override open func leftViewRect(forBounds bounds: CGRect) -> CGRect {
        return CGRect(x: _marginX!, y: (_selfFrame != nil) ? (_selfFrame!.height - _leftViewRect().height)*0.5: (bounds.height - _leftViewRect().height)*0.5, width: _leftViewRect().width, height: ceil(_leftViewRect().height))
    }
    
    override open func textRect(forBounds bounds: CGRect) -> CGRect {
        return _textRectWithBounds(bounds)
    }
    
    override open func editingRect(forBounds bounds: CGRect) -> CGRect {
        return _textRectWithBounds(bounds)
    }
    
    override open func placeholderRect(forBounds bounds: CGRect) -> CGRect {
        return _textRectWithBounds(bounds)
    }
    
    fileprivate func _leftViewRect() -> CGRect {
        if (leftViewMode == .never ||
            (leftViewMode == .unlessEditing && isEditing) ||
            (leftViewMode == .whileEditing && !isEditing)) {
            return .zero
        }
        return leftView!.frame
    }
    
    fileprivate func _rightViewRect() -> CGRect {
        if (rightViewMode == .never ||
            rightViewMode == .unlessEditing && isEditing ||
            rightViewMode == .whileEditing && !isEditing) {
            return .zero
        }
        return rightView!.bounds
    }
    
    
    //MARK: - Prompt Text
    /*
     **************************** Prompt Text ****************************
     */
    fileprivate func _setPromptText(_ text: String?) {
        if (text != nil) {
            var label = leftView
            if !(label is UILabel) {
                label = UILabel(frame: .zero)
                label?.frame.origin.x += _marginX!
                leftViewMode = .always
            }
            (label as! UILabel).text = text
            (label as! UILabel).font = font
            (label as! UILabel).textColor = promptTextColor
            (label as! UILabel).sizeToFit()
            leftView = label
            
        } else {
            leftView = nil
        }
        _setScrollRect()
    }
    
    
    //MARK: - Placeholder
    /*
     **************************** Placeholder ****************************
     */
    
    fileprivate func _updateText() {
        if (!_setupCompleted) {return}
        _initPlaceholderLabel()
        
        switch(_state) {
            case .opened:
                text = SwiftTokenTextEmpty
                break
                
            case .closed:
                if tokens.count == 0 {
                    text = SwiftTokenTextEmpty
                    
                } else {
                    var title = SwiftTokenTextEmpty
                    for token: SwiftToken in tokens {
                        title += "\(token.title)\(_separatorText!)"
                    }
                    
                    if (title.count > 0) {
                        title = String(title[..<title.index(title.endIndex, offsetBy: -_separatorText!.count)])
                    }
                    
                    let width = SwiftTokenUtils.widthOfString(title, font: font!)
                    if width + _leftViewRect().width > bounds.width {
                        text = "\(tokens.count) \(_descriptionText)"
                    } else {
                        text = title
                    }
                }
                break
        }
        _updatePlaceHolderVisibility()
    }
    
    fileprivate func _updatePlaceHolderVisibility() {
        if tokens.count == 0 && (text == SwiftTokenTextEmpty || text!.isEmpty) {
            _placeholderLabel?.text = _placeholderValue!
            _placeholderLabel?.sizeToFit()
            _placeholderLabel?.isHidden = false
            
        } else {
            _placeholderLabel?.isHidden = true
        }
    }
    
    fileprivate func _initPlaceholderLabel() {
        let xPos = _marginX!
        if (_placeholderLabel == nil) {
            _placeholderLabel = UILabel(frame: CGRect(x: xPos, y: leftView!.frame.origin.y, width: _selfFrame!.width - xPos - _leftViewRect().size.width, height: _leftViewRect().size.height))
            _placeholderLabel?.textColor = placeHolderColor
            _placeholderLabel?.font = _font
            _scrollView.addSubview(_placeholderLabel!)
        } else {
            _placeholderLabel?.frame.origin.x = xPos
        }
    }
    
    
    //MARK: - Token Gestures
    //__________________________________________________________________________________
    //
    func isSelectedToken(_ token: SwiftToken) -> Bool {
        if token.isEqual(selectedToken) {
            return true
        }
        return false
    }
    
    
    func deselectSelectedToken() {
        selectedToken?.isSelected = false
        selectedToken = nil
    }
    
    func selectToken(_ token: SwiftToken) {
        if (token.sticky) {
            return
        }
        for token: SwiftToken in tokens {
            if isSelectedToken(token) {
                deselectSelectedToken()
                break
            }
        }
        
        token.isSelected = true
        selectedToken = token
        tokenFieldDelegate?.tokenFieldDidSelectToken?(token)
    }
    
    @objc func tokenTouchDown(_ token: SwiftToken) {
        if (selectedToken != nil) {
            selectedToken?.isSelected = false
            selectedToken = nil
        }
    }
    
    @objc func tokenTouchUpInside(_ token: SwiftToken) {
        selectToken(token)
    }
    
    override open func beginTracking(_ touch: UITouch, with event: UIEvent?) -> Bool {
        if (touch.view == self) {
            deselectSelectedToken()
        }
        return super.beginTracking(touch, with: event)
    }
    
    @objc func tokenFieldTextDidChange(_ textField: UITextField) {
        _updatePlaceHolderVisibility()
    }
    
    // MARK: - Other Methods
    
    func paddingX() -> CGFloat? {
        return _paddingX
    }
    
    func tokenFont() -> UIFont? {
        return _font
    }
    
    func objects() -> NSArray {
        let objects = NSMutableArray()
        for object: AnyObject in tokens {
            objects.add(object)
        }
        return objects
    }
    
    override open func becomeFirstResponder() -> Bool {
        super.becomeFirstResponder()
        tokenFieldDelegate?.tokenFieldDidBeginEditing?(self)
        return true
    }
    
    @discardableResult override open func resignFirstResponder() -> Bool {
        tokenFieldDelegate?.tokenFieldDidEndEditing?(self)
        return super.resignFirstResponder()
    }
    
}


//MARK: - UIScrollViewDelegate
//__________________________________________________________________________________
//
extension SwiftTokenField : UIScrollViewDelegate {
    public func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        _scrollPoint = scrollView.contentOffset
    }
    
    public func scrollViewDidScroll(_ aScrollView: UIScrollView) {
        if (_state == .opened) {
            text = SwiftTokenTextEmpty
        }
        if (_direction == .horizontal) {
            aScrollView.contentOffset.y = 0
        } else {
            aScrollView.contentOffset.x = 0
        }
        updateCaretVisiblity(aScrollView)
    }
    
    func updateCaretVisiblity(_ aScrollView: UIScrollView) {
        switch _direction {
            case .vertical:
                let scrollViewHeight = aScrollView.frame.size.height;
                let scrollContentSizeHeight = aScrollView.contentSize.height;
                let scrollOffset = aScrollView.contentOffset.y;
                
                if (scrollOffset + scrollViewHeight < scrollContentSizeHeight - 10) {
                    hideCaret()
                    
                } else if (scrollOffset + scrollViewHeight >= scrollContentSizeHeight - 10) {
                    showCaret()
                }
                
            case .horizontal:
                let scrollViewWidth = aScrollView.frame.size.width;
                let scrollContentSizeWidth = aScrollView.contentSize.width;
                let scrollOffset = aScrollView.contentOffset.x;
                
                if (scrollOffset + scrollViewWidth < scrollContentSizeWidth - 10) {
                    hideCaret()
                    
                } else if (scrollOffset + scrollViewWidth >= scrollContentSizeWidth - 10) {
                    showCaret()
                }
                
        }
    }
    
    func hideCaret() {
        tintColor = UIColor.clear
    }
    
    func showCaret() {
        tintColor = _cursorColor
    }
}
