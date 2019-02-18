//
//  CardImageView.swift
//  X-Squad
//
//  Created by Avario on 03/01/2019.
//  Copyright © 2019 Avario. All rights reserved.
//
// This is a simple view that diplays the image for a card.

import Foundation
import UIKit
import Kingfisher

protocol CardViewDelegate: AnyObject {
	func cardViewDidForcePress(_ cardView: CardView, touches: Set<UITouch>, with event: UIEvent?)
}

class CardView: UIView {
	
	weak var delegate: CardViewDelegate?
	
	let cardContainer = UIView()
	private var imageView = UIImageView()
	var isVisible = true
	
	static var upgradeHiddenRatio: CGFloat = 0.395
	static var sizeRatio: CGFloat = 1.39
	static func heightMultiplier(for card: Card) -> CGFloat {
		switch card.orientation {
		case .portrait:
			return sizeRatio
		case .landscape:
			return 1/sizeRatio
		}
	}
	
	var card: Card? {
		didSet {
			guard let card = card else {
				return
			}
			
			imageView.kf.setImage(with: card.image)
		}
	}
	
	// The member is used to distinguish cards that might be the same but attached to different pilots during transitions.
	var member: Squad.Member?
	
	lazy var snap: UISnapBehavior = {
		let snap = UISnapBehavior(item: self, snapTo: self.center)
		return snap
	}()
	
	lazy var behaviour: UIDynamicItemBehavior = {
		let behaviour = UIDynamicItemBehavior(items: [self])
		behaviour.resistance = 10.0
		return behaviour
	}()
	
	var attachment: UIAttachmentBehavior?
	
	init() {
		super.init(frame: .zero)
		
		addSubview(cardContainer)
		cardContainer.translatesAutoresizingMaskIntoConstraints = false
		cardContainer.clipsToBounds = true
		cardContainer.layer.borderColor = UIColor.white.withAlphaComponent(0.15).cgColor
		
		cardContainer.topAnchor.constraint(equalTo: topAnchor).isActive = true
		cardContainer.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
		cardContainer.leftAnchor.constraint(equalTo: leftAnchor).isActive = true
		cardContainer.rightAnchor.constraint(equalTo: rightAnchor).isActive = true
		
		cardContainer.addSubview(imageView)
		imageView.translatesAutoresizingMaskIntoConstraints = false
		imageView.contentMode = .scaleAspectFit
		imageView.kf.indicatorType = .activity
		
		imageView.centerXAnchor.constraint(equalTo: cardContainer.centerXAnchor).isActive = true
		imageView.centerYAnchor.constraint(equalTo: cardContainer.centerYAnchor).isActive = true
		imageView.widthAnchor.constraint(equalTo: cardContainer.widthAnchor, multiplier: 1.008).isActive = true
		imageView.heightAnchor.constraint(equalTo: cardContainer.heightAnchor, multiplier: 1.008).isActive = true
	}
	
	required init?(coder aDecoder: NSCoder) {
		fatalError()
	}
	
	override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
		guard let touch = touches.first else {
			return
		}
		let percent = touch.force / touch.maximumPossibleForce
		if percent >= 0.7 {
			delegate?.cardViewDidForcePress(self, touches: touches, with: event)
		}
	}
	
	static func all(in view: UIView) -> [CardView] {
		var cardViews: [CardView] = []
		for subview in view.subviews {
			if let cardView = subview as? CardView, cardView.isVisible  {
				cardViews.append(cardView)
			}
			cardViews.append(contentsOf: CardView.all(in: subview))
		}
		return cardViews
	}
	
	func matches(_ cardView: CardView) -> Bool {
		if let upgrade = card as? Upgrade,
			let upgradeToMatch = cardView.card as? Upgrade {
			guard upgrade == upgradeToMatch else {
				return false
			}
		} else if let pilot = card as? Pilot,
			let pilotToMatch = cardView.card as? Pilot {
			guard pilot == pilotToMatch else {
				return false
			}
		} else {
			return false
		}
		
		guard member == cardView.member else {
			return false
		}
		
		return true
	}
	
	override func layoutSubviews() {
		super.layoutSubviews()

		cardContainer.layer.cornerRadius = bounds.width * 0.038
		cardContainer.layer.borderWidth = bounds.width * 0.0025
	}
	
}

