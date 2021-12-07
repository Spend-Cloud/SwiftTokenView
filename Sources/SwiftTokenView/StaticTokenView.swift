//
//  File.swift
//  
//
//  Created by Reshad Farid on 06/12/2021.
//

import UIKit

public protocol StaticToken {
    
    var id: Int { get }
    func tokenName() -> String
}

class CollectionViewRow {
    var attributes = [UICollectionViewLayoutAttributes]()
    var spacing: CGFloat = 0
    
    init(spacing: CGFloat) {
        self.spacing = spacing
    }
    
    func add(attribute: UICollectionViewLayoutAttributes) {
        attributes.append(attribute)
    }
    
    func centerLayout(collectionViewWidth: CGFloat) {
        let padding = CGFloat(8)
        var offset = padding
        for attribute in attributes {
            attribute.frame.origin.x = offset
            offset += attribute.frame.width + spacing
        }
    }
}

class StaticTokenLayout : UICollectionViewFlowLayout {

    override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        guard let attributes = super.layoutAttributesForElements(in: rect) else {
            return nil
        }
        
        var rows = [CollectionViewRow]()
        var currentRowY: CGFloat = -1
        
        for attribute in attributes {
            if currentRowY != attribute.frame.origin.y {
                currentRowY = attribute.frame.origin.y
                rows.append(CollectionViewRow(spacing: 4))
            }
            rows.last?.add(attribute: attribute)
        }
        
        rows.forEach { $0.centerLayout(collectionViewWidth: collectionView?.frame.width ?? 0) }
        return rows.flatMap { $0.attributes }
    }
}

public class StaticTokenView : UIView, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout, UICollectionViewDataSource {
    
    let placeholderLabel = UILabel(frame: CGRect(x: 8, y: 0, width: 200, height: 50))
    
    private let collectionView: UICollectionView = {
        
        let layout = StaticTokenLayout()
        layout.estimatedItemSize = CGSize(width: 50, height: 24)
        layout.minimumLineSpacing = 4
        let view = UICollectionView(frame: .zero, collectionViewLayout: layout)
        view.backgroundColor = UIColor.systemBackground
        view.translatesAutoresizingMaskIntoConstraints = false
        
        return view
    }()
    
    private var tokens = [StaticToken]()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setupView()
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupView()
    }
    
    public func addToken(_ token: StaticToken) {
        
        tokens.append(token)
        collectionView.reloadData()
        
    }
    
    public func addTokens(_ tokens: [StaticToken]) {
        
        if tokens.count > 5 {
            self.tokens.removeAll()
            
            addPlaceholder(for: tokens)
            
        } else {
            self.tokens = tokens
            removePlaceholder()
        }
        collectionView.reloadData()
    }
    
    public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell: StaticTokenFieldCollectionViewCell = collectionView.dequeueReusableCell(for: indexPath)
        
        let token = tokens[indexPath.item]
        cell.configure(with: token.tokenName())
        return cell
        
    }
    
    public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return tokens.count
    }
    
    public func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        let token = tokens[indexPath.item]
        let font: UIFont = UIFont.systemFont(ofSize: 15)
        
        let size = token.tokenName().size(withAttributes: [NSAttributedString.Key.font: font])
        let width = size.width + 16
        
        return CGSize(width: width, height: 24)
    }
    
    private func setupView() {
        collectionView.delegate = self
        collectionView.dataSource = self
        
        collectionView.register(StaticTokenFieldCollectionViewCell.self)

        addSubview(collectionView)
        collectionView.pinTo(self)
        
    }
    
    private func addPlaceholder(for tokens: [StaticToken]) {
        
        placeholderLabel.text = String(format: NSLocalizedString("%@ selected", comment: ""), "\(tokens.count)")
        collectionView.addSubview(placeholderLabel)
        collectionView.layoutIfNeeded()
    }
    
    private func removePlaceholder() {
        
        placeholderLabel.removeFromSuperview()
        collectionView.layoutIfNeeded()
    }
}

class StaticTokenFieldCollectionViewCell: UICollectionViewCell, ReusableView {
    
    var titleLabel: UILabel!
    
    func configure(with title: String) {
        titleLabel = UILabel()
        titleLabel.text = title
        titleLabel.textColor = .white
        titleLabel.font = UIFont.systemFont(ofSize: UIFont.systemFontSize)
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        self.addSubview(titleLabel)
        titleLabel.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 8).isActive = true
        titleLabel.topAnchor.constraint(equalTo: self.topAnchor, constant: 8).isActive = true
        titleLabel.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -8).isActive = true
        titleLabel.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: -8).isActive = true
        self.layer.cornerRadius = 10
        self.backgroundColor = .blue
    }
    
    override func prepareForReuse() {
        titleLabel = UILabel()
    }
}

protocol ReusableView: AnyObject {
    static var cellReuseIdentifier: String { get }
}

extension ReusableView where Self: UIView {
    static var cellReuseIdentifier: String {
        return String(describing: self)
    }
}

extension UIView {
    
    func pinTo(_ view: UIView, padding: CGFloat = 0) {
        
        self.translatesAutoresizingMaskIntoConstraints = false
        
        self.leftAnchor.constraint(equalTo: view.leftAnchor, constant: padding).isActive = true
        self.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -padding).isActive = true
        self.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: padding).isActive = true
        self.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: padding).isActive = true
    }
}

extension UICollectionView {
    func register<T: UICollectionViewCell>(_: T.Type) where T: ReusableView {
        register(T.self, forCellWithReuseIdentifier: T.cellReuseIdentifier)
    }
    
    func dequeueReusableCell<T: UICollectionViewCell>(for indexPath: IndexPath) -> T where T: ReusableView {
        guard let cell = dequeueReusableCell(withReuseIdentifier: T.cellReuseIdentifier, for: indexPath) as? T else {
            fatalError("Could not dequeue cell with identifier: \(T.cellReuseIdentifier)")
        }
        
        return cell
    }
}
