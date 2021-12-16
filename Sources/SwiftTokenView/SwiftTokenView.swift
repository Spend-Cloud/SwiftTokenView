//
//  StaticTokenView.swift
//
//
//  Created by Reshad Farid on 16/12/2021.
//

import SwiftUI

public struct SwiftTokenView: UIViewRepresentable {
    
    public let style: TokenStyle
    @Binding public var tokens: [StaticToken]
    
    public init(tokenStyle: TokenStyle? = nil, tokens: Binding<[StaticToken]>) {
        self.style = tokenStyle ?? DefaultStyle()
        self._tokens = tokens
    }
    
    public func makeUIView(context: Context) -> some StaticTokenView {
        let view = StaticTokenView()
        view.style = style
        return view
    }
    
    public func updateUIView(_ uiView: UIViewType, context: Context) {
        (uiView as StaticTokenView).addTokens(tokens)
    }
}
