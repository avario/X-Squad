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
	func collectionView(_ collectionView: UICollectionView, shouldShowHeaderFor section: Int) -> Bool
}

class CardCollectionViewLayout: UICollectionViewLayout {
	
	init(numberOfColumns: Int) {
		self.numberOfColumns = numberOfColumns
		super.init()
	}
	
	required init?(coder aDecoder: NSCoder) {
		fatalError()
	}
	
	enum CardOrientation {
		case portrait
		case landscape
	}
	
	weak var delegate: CardCollectionViewLayoutDelegate!
	
	fileprivate let numberOfColumns: Int
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

		var yOffset = [CGFloat](repeating: 0, count: numberOfColumns)
		
		let portraitHeight = columnWidth * CardView.sizeRatio
		let landscapeHeight = columnWidth / CardView.sizeRatio
		let headerHeight: CGFloat = 44
		
		for section in 0 ..< collectionView.numberOfSections {
			
			if delegate.collectionView(collectionView, shouldShowHeaderFor: section) {
				let longestColumnOffset = yOffset.max() ?? yOffset[0]
				
				let headerFrame = CGRect(x: 0, y: longestColumnOffset, width: contentWidth, height: headerHeight)
				let attributes = UICollectionViewLayoutAttributes(forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, with: IndexPath(item: 0, section: section))
				attributes.frame = headerFrame
				cache.append(attributes)
				
				yOffset = [CGFloat](repeating: headerFrame.maxY + cellSpacing, count: numberOfColumns)
			}
			
			for item in 0 ..< collectionView.numberOfItems(inSection: section) {
				
				let shortestColumn = yOffset.firstIndex(of: yOffset.min() ?? 0) ?? 0
				let column = shortestColumn
				
				let indexPath = IndexPath(item: item, section: section)
				
				let cardOrientation = delegate.collectionView(collectionView, orientationForCardAtIndexPath: indexPath)
				let height: CGFloat
				switch cardOrientation {
				case .portrait:
					height = portraitHeight
				case .landscape:
					height = landscapeHeight
				}
				
				let cellFrame = CGRect(x: xOffset[column], y: yOffset[column], width: columnWidth, height: height)
				
				let attributes = UICollectionViewLayoutAttributes(forCellWith: indexPath)
				attributes.frame = cellFrame
				cache.append(attributes)
				
				contentHeight = max(contentHeight, cellFrame.maxY)
				yOffset[column] = yOffset[column] + height + cellSpacing
			}
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
