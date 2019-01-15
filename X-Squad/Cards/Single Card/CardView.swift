//
//  CardImageView.swift
//  X-Squad
//
//  Created by Avario on 03/01/2019.
//  Copyright © 2019 Avario. All rights reserved.
//

import Foundation
import UIKit
import Kingfisher

class CardView: UIView {
	
	var imageView = UIImageView()
	var isVisible = true
	
	static var upgradeHiddenRatio: CGFloat = 0.39
	static var sizeRatio: CGFloat = 1.39
	static func heightMultiplier(for card: Card) -> CGFloat {
		switch card.type {
		case .pilot:
			return sizeRatio
		case .upgrade:
			return 1/sizeRatio
		}
	}
	
	var card: Card? {
		didSet {
			guard let card = card else {
				return
			}
			
			imageView.kf.setImage(with: card.cardImageURL)
			costView.cost = card.cost
		}
	}
	
	var id: String?
	
	lazy var snap: UISnapBehavior = {
		let snap = UISnapBehavior(item: self, snapTo: self.center)
		snap.damping = 1.0
		return snap
	}()
	
	lazy var behaviour: UIDynamicItemBehavior = {
		let behaviour = UIDynamicItemBehavior(items: [self])
		behaviour.resistance = 2.0
		behaviour.density = 2.0
		behaviour.angularResistance = 2.0
		return behaviour
	}()
	
	var attachment: UIAttachmentBehavior?
	
	let costView = CostView()
	
	init() {
		super.init(frame: .zero)
		
		addSubview(imageView)
		imageView.translatesAutoresizingMaskIntoConstraints = false
		imageView.contentMode = .scaleAspectFit
		imageView.clipsToBounds = true
		
		#warning("Does this actually improve performance?")
		imageView.layer.shouldRasterize = true
		imageView.layer.rasterizationScale = UIScreen.main.scale
		imageView.kf.indicatorType = .activity
		
		imageView.topAnchor.constraint(equalTo: topAnchor).isActive = true
		imageView.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
		imageView.leftAnchor.constraint(equalTo: leftAnchor).isActive = true
		imageView.rightAnchor.constraint(equalTo: rightAnchor).isActive = true
	}
	
	required init?(coder aDecoder: NSCoder) {
		fatalError()
	}
	
	static func all(in view: UIView) -> [CardView] {
		var cardViews: [CardView] = []
		for subview in view.subviews {
			if let cardView = subview as? CardView {//, cardView.isVisible  {
				cardViews.append(cardView)
			}
			cardViews.append(contentsOf: CardView.all(in: subview))
		}
		return cardViews
	}
	
	static func with(id: String, in view: UIView) -> CardView? {
		for subview in view.subviews {
			if let cardView = subview as? CardView, cardView.id == id  {
				return cardView
			}
			
			if let matchingCardView = CardView.with(id: id, in: subview) {
				return matchingCardView
			}
		}
		return nil
	}
	
	override func layoutSubviews() {
		super.layoutSubviews()
		
		imageView.layer.cornerRadius = frame.width * 0.038
		imageView.layer.borderColor = UIColor.white.withAlphaComponent(0.15).cgColor
		imageView.layer.borderWidth = frame.width * 0.0025
	}
	
}

