//
//  SwiftTokenTextField.swift
//  
//
//  Created by Reshad Farid on 21/12/2021.
//

import UIKit

@objc public enum SwiftTokenTextFieldStyle: Int {
    case rounded
    case squared
}

//MARK: - SwiftTokenTextFieldDelegate
//__________________________________________________________________________________
//
@objc public protocol SwiftTokenTextFieldDelegate {
    
    /**
     Asks the delegate whether the token should be added
     
     - parameter tokenView: SwiftTokenTextField object
     - parameter token:     SwiftToken object that needs to be added
     
     - returns: Boolean
     
     */
    @objc optional func tokenView(_ tokenView: SwiftTokenTextField, shouldAddToken token: SwiftToken) -> Bool
    @objc optional func tokenView(_ tokenView: SwiftTokenTextField, willAddToken token: SwiftToken)
    @objc optional func tokenView(_ tokenView: SwiftTokenTextField, shouldChangeAppearanceForToken token: SwiftToken) -> SwiftToken?
    @objc optional func tokenView(_ tokenView: SwiftTokenTextField, didAddToken token: SwiftToken)
    @objc optional func tokenView(_ tokenView: SwiftTokenTextField, didFailToAdd token: SwiftToken)
    
    @objc optional func tokenView(_ tokenView: SwiftTokenTextField, shouldDeleteToken token: SwiftToken) -> Bool
    @objc optional func tokenView(_ tokenView: SwiftTokenTextField, willDeleteToken token: SwiftToken)
    @objc optional func tokenView(_ tokenView: SwiftTokenTextField, didDeleteToken token: SwiftToken)
    @objc optional func tokenView(_ tokenView: SwiftTokenTextField, didFailToDeleteToken token: SwiftToken)
    
    @objc optional func tokenView(_ tokenView: SwiftTokenTextField, willChangeFrameWithX: CGFloat, y: CGFloat, width: CGFloat, height: CGFloat)
    @objc optional func tokenView(_ tokenView: SwiftTokenTextField, didChangeFrameWithX: CGFloat, y: CGFloat, width: CGFloat, height: CGFloat)
    
    @objc optional func tokenView(_ tokenView: SwiftTokenTextField, didSelectToken token: SwiftToken)
    @objc optional func tokenViewDidBeginEditing(_ tokenView: SwiftTokenTextField)
    @objc optional func tokenViewDidEndEditing(_ tokenView: SwiftTokenTextField)
    
    @objc func tokenView(_ tokenView: SwiftTokenTextField, performSearchWithString string: String, completion: ((_ results: Array<AnyObject>) -> Void)?)
    @objc func tokenView(_ tokenView: SwiftTokenTextField, displayTitleForObject object: AnyObject) -> String
    @objc optional func tokenView(_ tokenView: SwiftTokenTextField, withObject object: AnyObject, tableView: UITableView, cellForRowAtIndexPath indexPath: IndexPath) -> UITableViewCell
    @objc optional func tokenView(_ tokenView: SwiftTokenTextField, didSelectRowAtIndexPath indexPath: IndexPath)
    
    @objc optional func tokenViewShouldDeleteAllToken(_ tokenView: SwiftTokenTextField) -> Bool
    @objc optional func tokenViewWillDeleteAllToken(_ tokenView: SwiftTokenTextField)
    @objc optional func tokenViewDidDeleteAllToken(_ tokenView: SwiftTokenTextField)
    @objc optional func tokenViewDidFailToDeleteAllTokens(_ tokenView: SwiftTokenTextField)
    
    @objc optional func tokenViewDidShowSearchResults(_ tokenView: SwiftTokenTextField)
    @objc optional func tokenViewDidHideSearchResults(_ tokenView: SwiftTokenTextField)
}

open class SwiftTokenTextField: UIView {
    
    //MARK: - Private Properties
    //__________________________________________________________________________________
    //
    fileprivate var _tokenField: SwiftTokenField!
    fileprivate var _searchTableView: UITableView = UITableView(frame: .zero, style: UITableView.Style.plain)
    fileprivate var _resultArray = [AnyObject]()
    fileprivate var _showingSearchResult = false
    fileprivate var _indicator = UIActivityIndicatorView(style: UIActivityIndicatorView.Style.medium)
    fileprivate var _searchResultHeight: CGFloat = 200.0
    fileprivate var _lastSearchString: String = ""
    fileprivate var _intrinsicContentHeight: CGFloat = UIView.noIntrinsicMetric
    
    //MARK: - Public Properties
    //__________________________________________________________________________________
    //
    
    /// returns the value of field
    @objc open var text : String {
        get {
            return String(_tokenField.text![_tokenField.text!.startIndex..<self._tokenField.text!.endIndex])
        }
        set (string) {
            _tokenField.text = SwiftTokenTextEmpty+string
        }
    }
    
    /// default is true. token can be deleted with keyboard 'x' button
    @objc open var shouldDeleteTokenOnBackspace = true
    
    /// Only works for iPhone now, not iPad devices. default is false. If true, search results are hidden when one of them is selected
    @objc open var shouldHideSearchResultsOnSelect = false
    
    /// default is false. If true, already added token still appears in search results
    @objc open var shouldDisplayAlreadyTokenized = false
    
    /// default is ture. Sorts the search results alphabatically according to title provided by tokenView(_:displayTitleForObject) delegate
    @objc open var shouldSortResultsAlphabatically = true
    
    /// default is true. If false, token can only be added from picking search results. All the text input would be ignored
    @objc open var shouldAddTokenFromTextInput = true
    
    /// default is 1. If set to 0, it shows all search results without typing anything
    @objc open var minimumCharactersToSearch = 1
    
    /// default is nil
    @objc weak open var delegate: SwiftTokenTextFieldDelegate?
    
    /// default is .Vertical.
    @objc open var direction: SwiftTokenTextFieldScrollDirection = .vertical {
        didSet {
            _updateTokenField()
        }
    }
    
    /// Default is whiteColor
    @objc override open var backgroundColor: UIColor? {
        didSet {
            if (oldValue != backgroundColor && _tokenField != nil) {
                _tokenField.backgroundColor = backgroundColor
            }
        }
    }
    
    /// Default is (TokenViewWidth, 200)
    @objc open var searchResultHeight: CGFloat = 200 {
        didSet {
            _searchResultHeight = searchResultHeight
            _searchTableView.frame.size.height = searchResultHeight
        }
    }
    
    /// Default is whiteColor()
    @objc open var searchResultBackgroundColor: UIColor = UIColor.white {
        didSet {
            _searchTableView.backgroundColor = searchResultBackgroundColor
        }
    }
    
    /// default is UIColor.blueColor()
    @objc open var activityIndicatorColor: UIColor = UIColor.blue {
        didSet {
            _indicator.color = activityIndicatorColor
        }
    }
    
    /// default is 120.0. After maximum limit is reached, tokens starts scrolling vertically
    @objc open var maximumHeight: CGFloat = 120.0 {
        didSet {
            _tokenField.maximumHeight = maximumHeight
        }
    }
    
    /// default is UIColor.grayColor()
    @objc open var cursorColor: UIColor = UIColor.gray {
        didSet {
            _updateTokenField()
        }
    }
    
    /// default is 10.0. Horizontal padding of title
    @objc open var paddingX: CGFloat = 10.0 {
        didSet {
            if (oldValue != paddingX) {
                _updateTokenField()
            }
        }
    }
    
    /// default is 2.0. Vertical padding of title
    @objc open var paddingY: CGFloat = 2.0 {
        didSet {
            if (oldValue != paddingY) {
                _updateTokenField()
            }
        }
    }
    
    /// default is 5.0. Horizontal margin between tokens
    @objc open var marginX: CGFloat = 5.0 {
        didSet {
            if (oldValue != marginX) {
                _updateTokenField()
            }
        }
    }
    
    /// default is 5.0. Vertical margin between tokens
    @objc open var marginY: CGFloat = 5.0 {
        didSet {
            if (oldValue != marginY) {
                _updateTokenField()
            }
        }
    }
    
    /// default is 0. Horizontal buffer between prompt and content
    @objc open var bufferX: CGFloat = 0.0 {
        didSet {
            if (oldValue != bufferX) {
                _updateTokenField()
            }
        }
    }
    
    /// default is UIFont.systemFontOfSize(16)
    @objc open var font: UIFont = UIFont.systemFont(ofSize: 16) {
        didSet {
            if (oldValue != font) {
                _updateTokenField()
            }
        }
    }
    
    /// default is 50.0. Caret moves to new line if input width is less than this value
    @objc open var minWidthForInput: CGFloat = 50.0 {
        didSet {
            if (oldValue != minWidthForInput) {
                _updateTokenField()
            }
        }
    }
    
    /// default is ", ". Used to separate titles when untoknized
    @objc open var separatorText: String = ", " {
        didSet {
            if (oldValue != separatorText) {
                _updateTokenField()
            }
        }
    }
    
    /// An array of string values. Default values are "." and ",". Token is created with typed text, when user press any of the character mentioned in this Array
    @objc open var tokenizingCharacters = [".", ","]
    
    /// default is 0.25.
    @objc open var animateDuration: TimeInterval = 0.25 {
        didSet {
            if (oldValue != animateDuration) {
                _updateTokenField()
            }
        }
    }
    
    /// default is true. When resignFirstResponder is called tokens are removed and description is displayed.
    @objc open var removesTokensOnEndEditing: Bool = true {
        didSet {
            if (oldValue != removesTokensOnEndEditing) {
                _updateTokenField()
            }
        }
    }
    
    /// Default is "selections"
    @objc open var descriptionText: String = "selections" {
        didSet {
            if (oldValue != descriptionText) {
                _updateTokenField()
            }
        }
    }
    
    /// set -1 for unlimited.
    @objc open var maxTokenLimit: Int = -1 {
        didSet {
            if (oldValue != maxTokenLimit) {
                _updateTokenField()
            }
        }
    }
    
    /// default is "To: "
    @objc open var promptText: String = "To: " {
        didSet {
            if (oldValue != promptText) {
                _updateTokenField()
            }
        }
    }
    
    /// default is true. If false, cannot be edited
    @objc open var editable: Bool = true {
        didSet {
            _tokenField.isEnabled = editable
        }
    }
    
    /// default is nil
    @objc open var placeholder: String {
        get {
            return _tokenField.placeholder!
        }
        set {
            _tokenField.placeholder = newValue
        }
    }
    
    /// default is UIColor.grayColor()
    @objc open var promptColor: UIColor = UIColor.gray {
        didSet {
            _updateTokenField()
        }
    }
    
    /// default is UIColor.grayColor()
    @objc open var placeholderColor: UIColor = UIColor.gray {
        didSet {
            _updateTokenField()
        }
    }
    
    /// default is .Rounded, creates rounded corner
    @objc open var style: SwiftTokenTextFieldStyle = .rounded {
        didSet(newValue) {
            _updateTokenFieldLayout(style)
        }
    }
    
    //MARK: - Constructors
    //__________________________________________________________________________________
    //
    
    /**
     Create and inialize SwiftTokenTextField object
     
     - parameter frame: An object of type CGRect
     
     - returns: SwiftTokenTextField object
     */
    override public init(frame: CGRect) {
        super.init(frame: frame)
        _commonSetup()
    }
    
    /**
     Create and inialize SwiftTokenTextField object from Interface builder
     
     - parameter aDecoder: An object of type NSCoder
     
     - returns: SwiftTokenTextField object
     */
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        _commonSetup()
    }
    
    override open func awakeFromNib() {
        _commonSetup()
    }
    
    //MARK: - Common Setup
    //__________________________________________________________________________________
    //
    
    fileprivate func _commonSetup() {
        backgroundColor = UIColor.clear
        clipsToBounds = true
        _tokenField = SwiftTokenField(frame: CGRect(x: 0, y: 0, width: self.bounds.width, height: self.bounds.height))
        _tokenField.textColor = UIColor.black
        _tokenField.isEnabled = true
        _tokenField.tokenFieldDelegate = self
        _tokenField.placeholder = ""
        _tokenField.autoresizingMask = [.flexibleWidth]
        _updateTokenField()
        addSubview(_tokenField)
        
        _indicator.frame = CGRect(x: 0, y: 0, width: 30, height: 30)
        _indicator.hidesWhenStopped = true
        _indicator.stopAnimating()
        _indicator.color = activityIndicatorColor
        
        _searchTableView.frame = CGRect(x: 0, y: frame.height, width: frame.width, height: _searchResultHeight)
        _searchTableView.delegate = self
        _searchTableView.dataSource = self
        
        _hideSearchResults()
        _intrinsicContentHeight = _tokenField.bounds.height
        invalidateIntrinsicContentSize()
    }
    
    //MARK: - Layout Changes
    //__________________________________________________________________________________
    //
    override open func layoutSubviews() {
        _tokenField.updateLayout(false)
        _searchTableView.frame.size = CGSize(width: frame.width, height: _searchResultHeight)
    }
    
    override open var intrinsicContentSize : CGSize {
        return CGSize(width: UIView.noIntrinsicMetric, height: _intrinsicContentHeight)
    }
    
    //MARK: - Public Methods
    //__________________________________________________________________________________
    //
    
    /// Changes the returnKeyType of SwiftTokenField
    open func returnKeyType(type: UIReturnKeyType) {
        _tokenField.returnKeyType = type
    }
    
    //MARK: - Private Methods
    //__________________________________________________________________________________
    //
    
    fileprivate func _updateTokenField() {
        _tokenField.parentView = self
    }
    
    fileprivate func _updateTokenFieldLayout(_ newValue: SwiftTokenTextFieldStyle) {
        switch (newValue) {
            case .rounded:
                _tokenField.borderStyle = .roundedRect
                backgroundColor = UIColor.clear
                
            case .squared:
                _tokenField.borderStyle = .bezel
                backgroundColor = _tokenField.backgroundColor
        }
    }
    
    fileprivate func _lastToken() -> SwiftToken? {
        if _tokenField.tokens.count == 0 {
            return nil
        }
        return _tokenField.tokens.last
    }
    
    fileprivate func _removeToken(_ token: SwiftToken, removingAll: Bool = false) {
        if token.sticky {return}
        if (!removingAll) {
            var shouldRemoveToken: Bool? = true
            
            if let shouldRemove = delegate?.tokenView?(self, shouldDeleteToken: token) {
                shouldRemoveToken = shouldRemove
            }
            if (shouldRemoveToken != true) {
                delegate?.tokenView?(self, didFailToDeleteToken: token)
                return
            }
            delegate?.tokenView?(self, willDeleteToken: token)
        }
        _tokenField.removeToken(token, removingAll: removingAll)
        if (!removingAll) {
            delegate?.tokenView?(self, didDeleteToken: token)
            _startSearchWithString("")
        }
    }
    
    fileprivate func _canAddMoreToken() -> Bool {
        if (maxTokenLimit != -1 && _tokenField.tokens.count >= maxTokenLimit) {
            _hideSearchResults()
            return false
        }
        return true
    }
    
    
    /**
     Returns an Array of SwiftToken objects
     
     - returns: Array of SwiftToken objects
     */
    open func tokens () -> Array<SwiftToken>? {
        return _tokenField.tokens
    }
    
    //MARK: - Add Token
    //__________________________________________________________________________________
    //
    
    
    /**
     Creates SwiftToken from input text, when user press keyboard "Done" button
     
     - parameter tokenField: Field to add in
     
     - returns: Boolean if token is added
     */
    fileprivate func _addTokenFromUntokenizedText(_ tokenField: SwiftTokenField) -> Bool {
        if (shouldAddTokenFromTextInput && tokenField.text != nil && tokenField.text != SwiftTokenTextEmpty) {
            let trimmedString = tokenField.text!.trimmingCharacters(in: CharacterSet.whitespaces)
            addTokenWithTitle(trimmedString)
            _hideSearchResults()
            return true
        }
        return false
    }
    
    /**
     Creates and add a new SwiftToken object
     
     - parameter title:       Title of token
     - parameter tokenObject: Any custom object
     
     - returns: SwiftToken object
     */
    @discardableResult open func addTokenWithTitle(_ title: String, tokenObject: AnyObject? = nil) -> SwiftToken? {
        let token = SwiftToken(title: title, object: tokenObject)
        return addToken(token)
    }
    
    
    /**
     Creates and add a new SwiftToken object
     
     - parameter token: SwiftToken object
     
     - returns: SwiftToken object
     */
    @discardableResult open func addToken(_ token: SwiftToken) -> SwiftToken? {
        if (!_canAddMoreToken()) {
            return nil
        }
        
        var shouldAddToken: Bool? = true
        if let shouldAdd = delegate?.tokenView?(self, shouldAddToken: token) {
            shouldAddToken = shouldAdd
        }
        
        if (shouldAddToken != true) {
            delegate?.tokenView?(self, didFailToAdd: token)
            return nil
        }
        
        delegate?.tokenView?(self, willAddToken: token)
        var addedToken: SwiftToken?
        if let updatedToken = delegate?.tokenView?(self, shouldChangeAppearanceForToken: token) {
            addedToken = _tokenField.addToken(updatedToken)
            
        } else {
            addedToken = _tokenField.addToken(token)
        }
        
        delegate?.tokenView?(self, didAddToken: addedToken!)
        _ = _canAddMoreToken()
        return addedToken
    }
    
    
    //MARK: - Delete Token
    //__________________________________________________________________________________
    //
    
    /**
     Deletes an already added SwiftToken object
     
     - parameter token: SwiftToken object
     */
    open func deleteToken(_ token: SwiftToken) {
        _removeToken(token)
    }
    
    /**
     Searches for SwiftToken object and deletes
     
     - parameter object: Custom object
     */
    open func deleteTokenWithObject(_ object: AnyObject?) {
        if object == nil {return}
        for token in _tokenField.tokens {
            if (token.object!.isEqual(object)) {
                _removeToken(token)
                break
            }
        }
    }
    
    /**
     Deletes all added tokens. This doesn't delete sticky token
     */
    open func deleteAllTokens() {
        if (_tokenField.tokens.count == 0) {return}
        var shouldDeleteAllTokens: Bool? = true
        
        if let shouldRemoveAll = delegate?.tokenViewShouldDeleteAllToken?(self) {
            shouldDeleteAllTokens = shouldRemoveAll
        }
        
        if (shouldDeleteAllTokens != true) {
            delegate?.tokenViewDidFailToDeleteAllTokens?(self)
            return
        }
        
        delegate?.tokenViewWillDeleteAllToken?(self)
        for token in _tokenField.tokens {_removeToken(token, removingAll: true)}
        _tokenField.updateLayout()
        delegate?.tokenViewDidDeleteAllToken?(self)
        
        if (_showingSearchResult) {
            _startSearchWithString(_lastSearchString)
        }
    }
    
    /**
     Deletes last added SwiftToken object
     */
    open func deleteLastToken() {
        let token: SwiftToken? = _lastToken()
        if token != nil {
            _removeToken(token!)
        }
    }
    
    /**
     Deletes selected SwiftToken object
     */
    open func deleteSelectedToken() {
        let token: SwiftToken? = selectedToken()
        if (token != nil) {
            _removeToken(token!)
        }
    }
    
    /**
     Returns Selected SwiftToken object
     
     - returns: SwiftToken object
     */
    open func selectedToken() -> SwiftToken? {
        return _tokenField.selectedToken
    }
    
    
    //MARK: - SwiftTokenFieldDelegates
    //__________________________________________________________________________________
    //
    func tokenFieldDidBeginEditing(_ tokenField: SwiftTokenField) {
        delegate?.tokenViewDidBeginEditing?(self)
        tokenField.tokenize()
        if (minimumCharactersToSearch == 0) {
            _startSearchWithString("")
        }
    }
    
    func tokenFieldDidEndEditing(_ tokenField: SwiftTokenField) {
        delegate?.tokenViewDidEndEditing?(self)
        tokenField.untokenize()
        _hideSearchResults()
    }
    
    open override var isFirstResponder : Bool {
        return _tokenField.isFirstResponder
    }
    
    override open func becomeFirstResponder() -> Bool {
        return _tokenField.becomeFirstResponder()
    }
    
    @discardableResult override open func resignFirstResponder() -> Bool {
        if (!_addTokenFromUntokenizedText(_tokenField)) {
            _tokenField.resignFirstResponder()
        }
        return false
    }
    
    //MARK: - Search
    //__________________________________________________________________________________
    //
    
    /**
     Triggers the search after user input text
     
     - parameter string: Search keyword
     */
    fileprivate func _startSearchWithString(_ string: String) {
        if (!_canAddMoreToken()) {
            return
        }
        _showEmptyResults()
        _showActivityIndicator()
        
        let trimmedSearchString = string.trimmingCharacters(in: CharacterSet.whitespaces)
        delegate?.tokenView(self, performSearchWithString:trimmedSearchString, completion: { (results) -> Void in
            self._hideActivityIndicator()
            if (results.count > 0) {
                self._displayData(results)
            }
        })
    }
    
    fileprivate func _displayData(_ results: Array<AnyObject>) {
        _resultArray = _filteredSearchResults(results)
        _searchTableView.reloadData()
        _showSearchResults()
    }
    
    fileprivate func _showEmptyResults() {
        _resultArray.removeAll(keepingCapacity: false)
        _searchTableView.reloadData()
        _showSearchResults()
    }
    
    fileprivate func _showSearchResults() {
        guard !_showingSearchResult else {return}
        _showingSearchResult = true
        addSubview(_searchTableView)
        let tokenFieldHeight = _tokenField.frame.height
        _searchTableView.isHidden = false
        _changeHeight(tokenFieldHeight)
        delegate?.tokenViewDidShowSearchResults?(self)
    }
    
    fileprivate func _hideSearchResults() {
        guard _showingSearchResult else {return}
        _showingSearchResult = false
        let searchTableView = self._searchTableView
        _changeHeight(_tokenField.frame.height) {
            searchTableView.isHidden = true
            searchTableView.removeFromSuperview()
        }
        delegate?.tokenViewDidHideSearchResults?(self)
    }
    
    fileprivate func _repositionSearchResults(_ height: CGFloat) {
        if (!_showingSearchResult) {
            return
        }
        _searchTableView.frame.origin = CGPoint(x: 0, y: height)
    }
    
    fileprivate func _filteredSearchResults(_ results: Array <AnyObject>) -> Array <AnyObject> {
        var filteredResults: Array<AnyObject> = Array()
        
        for object: AnyObject in results {
            // Check duplicates in array
            var shouldAdd = !(filteredResults as NSArray).contains(object)
            
            if (shouldAdd) {
                if (!shouldDisplayAlreadyTokenized && _tokenField.tokens.count > 0) {
                    
                    // Search if already tokenized
                    for token: SwiftToken in _tokenField.tokens {
                        if (object.isEqual(token.object)) {
                            shouldAdd = false
                            break
                        }
                    }
                }
                
                if (shouldAdd) {
                    filteredResults.append(object)
                }
            }
        }
        
        if (shouldSortResultsAlphabatically) {
            return filteredResults.sorted(by: { s1, s2 in return self._sortStringForObject(s1) < self._sortStringForObject(s2) })
        }
        return filteredResults
    }
    
    fileprivate func _sortStringForObject(_ object: AnyObject) -> String {
        let title = (delegate?.tokenView(self, displayTitleForObject: object))!
        return title
    }
    
    fileprivate func _showActivityIndicator() {
        _indicator.startAnimating()
        _searchTableView.tableHeaderView = _indicator
    }
    
    fileprivate func _hideActivityIndicator() {
        _indicator.stopAnimating()
        _searchTableView.tableHeaderView = nil
    }
    
    fileprivate func _changeHeight(_ tokenFieldHeight: CGFloat, completion: (() -> Void)? = nil) {
        let fullHeight = tokenFieldHeight + (_showingSearchResult ? _searchResultHeight : 0.0)
        delegate?.tokenView?(self, willChangeFrameWithX: frame.origin.x, y: frame.origin.y, width: frame.size.width, height: fullHeight)
        self._repositionSearchResults(tokenFieldHeight)
        
        UIView.animate(
            withDuration: animateDuration,
            animations: {
                self._tokenField.frame.size.height = tokenFieldHeight
                self.frame.size.height = fullHeight
                self._intrinsicContentHeight = fullHeight
                self.invalidateIntrinsicContentSize()
                self.superview?.layoutIfNeeded()
            },
            completion: {completed in
                completion?()
                if (completed) {
                    self.delegate?.tokenView?(self, didChangeFrameWithX: self.frame.origin.x, y: self.frame.origin.y, width: self.frame.size.width, height: fullHeight)
                }
            })
    }
    
    //MARK: - Memory Mangement
    //__________________________________________________________________________________
    //
    deinit {
        
    }
}

extension SwiftTokenTextField : SwiftTokenFieldDelegate {
    internal func tokenFieldDidSelectToken(_ token: SwiftToken) {
        delegate?.tokenView?(self, didSelectToken: token)
    }
    
    func tokenFieldShouldChangeHeight(_ height: CGFloat) {
        _changeHeight(height)
    }
}


//MARK: - Extension UITextFieldDelegate
//__________________________________________________________________________________
//
extension SwiftTokenTextField : UITextFieldDelegate {
    public func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        
        // If backspace is pressed
        if (_tokenField.tokens.count > 0 && _tokenField.text == SwiftTokenTextEmpty && string.isEmpty == true && shouldDeleteTokenOnBackspace) {
            if (_lastToken() != nil) {
                if (selectedToken() != nil) {
                    deleteSelectedToken()
                } else {
                    _tokenField.selectToken(_lastToken()!)
                }
            }
            return false
        }
        
        // Prevent removing SwiftTokenTextEmpty
        if (string.isEmpty == true && _tokenField.text == SwiftTokenTextEmpty) {
            return false
        }
        
        var searchString: String
        let olderText = _tokenField.text
        var olderTextTrimmed = olderText!
        
        // remove the empty text marker from the beginning of the string
        if (olderText?.first == SwiftTokenTextEmpty.first) {
            olderTextTrimmed = String(olderText![olderText!.index(olderText!.startIndex, offsetBy: 1)..<olderText!.endIndex])
        }
        
        // Check if character is removed at some index
        // Remove character at that index
        if (string.isEmpty) {
            let first = String(olderText![..<olderText!.index(olderText!.startIndex, offsetBy: range.location)])
            let second = String(olderText![olderText!.index(olderText!.startIndex, offsetBy: range.location+1)..<olderText!.endIndex])
            searchString = first + second
            searchString = searchString.trimmingCharacters(in: CharacterSet.whitespaces)
            
        } else { // new character added
            if (tokenizingCharacters.contains(string) && olderText != SwiftTokenTextEmpty && olderTextTrimmed != "") {
                addTokenWithTitle(olderTextTrimmed, tokenObject: nil)
                _hideSearchResults()
                return false
            }
            searchString = (olderText! as NSString).replacingCharacters(in: range, with: string)
            if (searchString.first == SwiftTokenTextEmpty.first) {
                searchString = String(searchString[1...])
            }
        }
        
        // Allow all other characters
        if (searchString.count >= minimumCharactersToSearch && searchString != "\n") {
            _lastSearchString = searchString
            _startSearchWithString(_lastSearchString)
        } else {
            _hideSearchResults()
        }
        
        _tokenField.scrollViewScrollToEnd()
        return true
    }
    
    public func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        resignFirstResponder()
        return true
    }
}

//MARK: - Extension UITableViewDelegate
//__________________________________________________________________________________
//
extension SwiftTokenTextField : UITableViewDelegate {
    
    public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        delegate?.tokenView?(self, didSelectRowAtIndexPath: indexPath)
        let object: AnyObject = _resultArray[(indexPath as NSIndexPath).row]
        let title  = delegate?.tokenView(self, displayTitleForObject: object)
        let token = SwiftToken(title: title!, object: object)
        addToken(token)
        
        if (shouldHideSearchResultsOnSelect) {
            _hideSearchResults()
            
        } else if (!shouldDisplayAlreadyTokenized) {
            _resultArray.remove(at: (indexPath as NSIndexPath).row)
            tableView.deleteRows(at: [indexPath], with: UITableView.RowAnimation.left)
        }
    }
}

//MARK: - Extension UITableViewDataSource
//__________________________________________________________________________________
//
extension SwiftTokenTextField : UITableViewDataSource {
    
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return _resultArray.count
    }
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        var cell: UITableViewCell? = delegate?.tokenView?(self, withObject: _resultArray[(indexPath as NSIndexPath).row], tableView: tableView, cellForRowAtIndexPath: indexPath)
        if cell != nil {
            return cell!
        }
        
        let cellIdentifier = "KSSearchTableCell"
        cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier) as UITableViewCell?
        if (cell == nil) {
            cell = UITableViewCell(style: UITableViewCell.CellStyle.default, reuseIdentifier: cellIdentifier)
        }
        
        let title = delegate?.tokenView(self, displayTitleForObject: _resultArray[(indexPath as NSIndexPath).row])
        cell!.textLabel!.text = (title != nil) ? title : "No Title"
        cell!.selectionStyle = UITableViewCell.SelectionStyle.none
        return cell!
    }
}
