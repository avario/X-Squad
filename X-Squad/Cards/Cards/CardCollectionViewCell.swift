//
//  CardCollectionViewCell.swift
//  X-Squad
//
//  Created by Avario on 03/01/2019.
//  Copyright © 2019 Avario. All rights reserved.
//

import Foundation
import UIKit
import Kingfisher

class CardCollectionViewCell: UICollectionViewCell {
	
	static let identifier = "CardCollectionViewCell"
	
	var card: Card? {
		didSet {
			cardView.card = card
			cardView.id = card?.defaultID
		}
	}
	
	var isCardAvailable: Bool = true {
		didSet {
			cardView.alpha = isCardAvailable ? 1.0 : 0.5
		}
	}
	
	let cardView = CardView()
	
	override init(frame: CGRect) {
		super.init(frame: frame)
		
		addSubview(cardView)
	}
	
	required init?(coder aDecoder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
	override func prepareForReuse() {
		super.prepareForReuse()
		card = nil
	}
	
	override func layoutSubviews() {
		super.layoutSubviews()
		
		cardView.frame = bounds
	}
	
}
