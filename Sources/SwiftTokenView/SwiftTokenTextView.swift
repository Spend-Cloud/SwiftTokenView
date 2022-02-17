//
//  SwiftTokenTextView.swift
//  
//
//  Created by Reshad Farid on 21/12/2021.
//

import SwiftUI

public struct SwiftTokenTextView: UIViewRepresentable {
    
    public class Coordinator: NSObject, SwiftTokenTextFieldDelegate {
        
        var parent: SwiftTokenTextView

        init(_ parent: SwiftTokenTextView) {
            self.parent = parent
        }
        
        public func tokenView(_ tokenView: SwiftTokenTextField, performSearchWithString string: String, completion: ((Array<AnyObject>) -> Void)?) {
            completion!(parent.performSearch?(string) ?? [])
        }
        
        public func tokenView(_ tokenView: SwiftTokenTextField, displayTitleForObject object: AnyObject) -> String {
            parent.displayTitleForObject?(object) ?? ""
        }

        public func tokenView(_ tokenView: SwiftTokenTextField, didAddToken token: SwiftToken) {
            parent.tokens.append(token)
        }
        
        public func tokenView(_ tokenView: SwiftTokenTextField, didDeleteToken token: SwiftToken) {
            if let index = parent.tokens.firstIndex(of: token) {
                parent.tokens.remove(at: index)
            } else {
                parent.tokens = tokenView.tokens() ?? []
            }
        }
        
        public func tokenView(_ tokenView: SwiftTokenTextField, shouldChangeAppearanceForToken token: SwiftToken) -> SwiftToken? {
            
            token.tokenBackgroundColor = parent.style.backgroundColor
            token.tokenTextColor = parent.style.textColor
            token.tokenBackgroundHighlightedColor = parent.style.backgroundColor.darkendColor(0.8)
            token.tokenTextHighlightedColor = parent.style.textColor
            
            return token
        }
    }
    
    @Binding var tokens: [SwiftToken]
    let width: Int
    let height: Int
    let style: TokenStyle
    var performSearch: ((String) -> [AnyObject])?
    var displayTitleForObject: ((AnyObject) -> String)?
    
    public init(tokenStyle: TokenStyle? = nil, width: Int, height: Int, tokens: Binding<[SwiftToken]>, performSearch: ((String) -> [AnyObject])? = nil, displayTitleForObject: ((AnyObject) -> String)? = nil) {
        self._tokens = tokens
        self.width = width
        self.height = height
        self.style = tokenStyle ?? DefaultStyle()
        self.performSearch = performSearch
        self.displayTitleForObject = displayTitleForObject
    }
    
    public func makeUIView(context: Context) -> some SwiftTokenTextField {
        let view = SwiftTokenTextField(frame: .init(x: 0, y: 0, width: width, height: height))
        view.descriptionText = NSLocalizedString("Selection", comment: "")
        view.style = .squared
        view.minimumCharactersToSearch = 0
        view.searchResultBackgroundColor = .tertiarySystemBackground
        view.shouldShowSearchResults = performSearch != nil
        view.promptColor = .secondaryLabel
        view.placeholderColor = .tertiaryLabel
        view.backgroundColor = .secondarySystemBackground
        view.shouldAddTokenFromTextInput = true
        view.tokenizingCharacters = [","]
        view.bufferX = 5.0
        view.layoutMargins = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 56)
        view.delegate = context.coordinator
        return view
    }
    
    public func updateUIView(_ uiView: UIViewType, context: Context) {}
    
    public func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
}
