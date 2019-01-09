//
//  CardCollectionViewLayout.swift
//  X-Squad
//
//  Created by Avario on 03/01/2019.
//  Copyright © 2019 Avario. All rights reserved.
//

import Foundation
import UIKit

protocol CardCollectionViewLayoutDelegate: class {
	func collectionView(_ collectionView: UICollectionView, orientationForCardAtIndexPath indexPath: IndexPath) -> CardCollectionViewLayout.CardOrientation
}

class CardCollectionViewLayout: UICollectionViewLayout {
	
	enum CardOrientation {
		case portrait
		case landscape
	}
	
	weak var delegate: CardCollectionViewLayoutDelegate!
	
	fileprivate var numberOfColumns = 2
	fileprivate var cellSpacing: CGFloat = 10
	
	fileprivate var cache = [UICollectionViewLayoutAttributes]()
	
	fileprivate var contentHeight: CGFloat = 0
	
	fileprivate var contentWidth: CGFloat {
		guard let collectionView = collectionView else {
			return 0
		}
		let insets = collectionView.contentInset
		return collectionView.bounds.width - (insets.left + insets.right)
	}
	
	override var collectionViewContentSize: CGSize {
		return CGSize(width: contentWidth, height: contentHeight)
	}
	
	override func prepare() {
		cache.removeAll()
		contentHeight = 0
		
		guard let collectionView = collectionView else {
			return
		}
		
		let columnWidth = (contentWidth - (cellSpacing * CGFloat(numberOfColumns - 1))) / CGFloat(numberOfColumns)
		var xOffset = [CGFloat]()
		for column in 0 ..< numberOfColumns {
			xOffset.append(CGFloat(column) * (columnWidth + cellSpacing))
		}
		var column = 0
		var yOffset = [CGFloat](repeating: 0, count: numberOfColumns)
		
		let portraitHeight = columnWidth * CardView.sizeRatio
		let landscapeHeight = columnWidth / CardView.sizeRatio
		
		for item in 0 ..< collectionView.numberOfItems(inSection: 0) {
			
			let indexPath = IndexPath(item: item, section: 0)
			
			let cardOrientation = delegate.collectionView(collectionView, orientationForCardAtIndexPath: indexPath)
			let height: CGFloat
			switch cardOrientation {
			case .portrait:
				height = portraitHeight
			case .landscape:
				height = landscapeHeight
			}
			
			let frame = CGRect(x: xOffset[column], y: yOffset[column], width: columnWidth, height: height)
			let insetFrame = frame
			
			let attributes = UICollectionViewLayoutAttributes(forCellWith: indexPath)
			attributes.frame = insetFrame
			cache.append(attributes)
			
			contentHeight = max(contentHeight, frame.maxY)
			yOffset[column] = yOffset[column] + height + cellSpacing
			
			column = yOffset.firstIndex(of: yOffset.min() ?? 0) ?? 0// column < (numberOfColumns - 1) ? (column + 1) : 0
		}
	}
	
	override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
		
		var visibleLayoutAttributes = [UICollectionViewLayoutAttributes]()
		
		for attributes in cache {
			if attributes.frame.intersects(rect) {
				visibleLayoutAttributes.append(attributes)
			}
		}
		return visibleLayoutAttributes
	}
	
	override func layoutAttributesForItem(at indexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
		return cache[indexPath.item]
	}
	
}
