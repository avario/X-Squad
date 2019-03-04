//
//  CardDetailsCollectionViewCell.swift
//  X-Squad
//
//  Created by Avario on 21/02/2019.
//  Copyright © 2019 Avario. All rights reserved.
//

import Foundation
import UIKit

protocol CardDetailsCollectionViewCellDelegate: AnyObject {
	func didPressSquadButton(for cardDetailsCollectionViewCell: CardDetailsCollectionViewCell)
}

class CardDetailsCollectionViewCell: UICollectionViewCell {
	
	static let reuseIdentifier = "CardDetailsCollectionViewCell"
	
	static private let isSpaceLimited = UIScreen.main.bounds.height < 600
	static private let horizontalPadding: CGFloat = 10
	static private let verticalCenterOffset: CGFloat = isSpaceLimited ? -15 : -20
	
	private(set) var pullToDismissController: PullToDismissController!
	
	var card: Card? {
		didSet {
			guard let card = card else {
				return
			}
			
			cardView.card = card
			
			let cardWidth = min(frame.width - CardDetailsCollectionViewCell.horizontalPadding * 2, 400)
			cardView.frame = CGRect(origin: .zero, size: CGSize(width: cardWidth, height: cardWidth * CardView.heightMultiplier(for: card)))
			cardView.center = CGPoint(x: bounds.midX , y: bounds.midY + CardDetailsCollectionViewCell.verticalCenterOffset)
			
			cardLayoutGuideHeightConstraint.constant = cardView.bounds.height
			cardLayoutGuideWidthConstraint.constant = cardView.bounds.width
			
			costView.isHidden = !card.isReleased
			unreleasedLabel.isHidden = card.isReleased
			hyperspaceLabel.isHidden = (card.hyperspace ?? false) == false
			
			switch card {
			case let pilot as Pilot:
				let ship = DataStore.ships.first(where: { $0.pilots.contains(pilot) })!
				
				dialView.isHidden = false
				dialView.ship = ship
				
				shipSizeLabel.text = ship.size.characterCode
				
				upgradeSlotsBar.isHidden = false
				upgradeSlotsBar.upgradeSlots = pilot.slots
				
				flipButton.isHidden = true
				
			case let upgrade as Upgrade:
				flipButton.isHidden = upgrade.backSide == nil
				dialView.isHidden = true
				shipSizeLabel.text = nil
				upgradeSlotsBar.isHidden = true
				
			default:
				fatalError()
			}
		}
	}
	
	var member: Squad.Member? {
		didSet {
			cardView.member = member
		}
	}
	
	var cost: Int = 0 {
		didSet {
			costView.cost = cost
		}
	}
	
	var squadAction: SquadButton.Action? {
		didSet {
			if let squadAction = squadAction {
				squadButton.action = squadAction
				squadButton.isHidden = false
			} else {
				squadButton.isHidden = true
			}
		}
	}
	
	weak var delegate: CardDetailsCollectionViewCellDelegate?
	
	let cardView = CardView()
	let cardScrollView = UIScrollView()
	let cardLayoutGuide = UILayoutGuide()
	var cardLayoutGuideHeightConstraint: NSLayoutConstraint!
	var cardLayoutGuideWidthConstraint: NSLayoutConstraint!

	let squadButton = SquadButton()
	let costView = CostView()
	let upgradeSlotsBar = UpgradeSlotsBar()
	let flipButton = SmallButton()
	let unreleasedLabel = UILabel()
	
	let underView = UIView()
	let hyperspaceLabel = UILabel()
	let shipSizeLabel = UILabel()
	let dialView = DialView()
	
	override init(frame: CGRect) {
		super.init(frame: frame)
		
		pullToDismissController = PullToDismissController(scrollView: cardScrollView)
		
		// Card layout guide
		addLayoutGuide(cardLayoutGuide)
		
		cardLayoutGuideHeightConstraint = cardLayoutGuide.heightAnchor.constraint(equalToConstant: 200)
		cardLayoutGuideHeightConstraint.isActive = true
		
		cardLayoutGuideWidthConstraint = cardLayoutGuide.widthAnchor.constraint(equalToConstant: 200)
		cardLayoutGuideWidthConstraint.isActive = true
		
		cardLayoutGuide.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
		cardLayoutGuide.centerYAnchor.constraint(equalTo: centerYAnchor, constant: CardDetailsCollectionViewCell.verticalCenterOffset).isActive = true
		
		// Card scroll view
		addSubview(cardScrollView)
		cardScrollView.clipsToBounds = false
		cardScrollView.alwaysBounceVertical = true
		cardScrollView.insetsLayoutMarginsFromSafeArea = false
		cardScrollView.contentInsetAdjustmentBehavior = .never
		
		cardScrollView.translatesAutoresizingMaskIntoConstraints = false
		cardScrollView.topAnchor.constraint(equalTo: topAnchor).isActive = true
		cardScrollView.rightAnchor.constraint(equalTo: rightAnchor).isActive = true
		cardScrollView.bottomAnchor.constraint(equalTo: cardLayoutGuide.bottomAnchor).isActive = true
		cardScrollView.leftAnchor.constraint(equalTo: leftAnchor).isActive = true
		
		cardScrollView.addSubview(cardView)
		cardView.isVisible = false
		
		// Squad button
		insertSubview(squadButton, belowSubview: cardScrollView)
		
		squadButton.addTarget(self, action: #selector(squadButtonPressed), for: .touchUpInside)
		squadButton.bottomAnchor.constraint(equalTo: safeAreaLayoutGuide.bottomAnchor).isActive = true
		squadButton.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
		
		let cardBottomPadding: CGFloat = CardDetailsCollectionViewCell.isSpaceLimited ? 10 : 15
		
		// Cost view
		insertSubview(costView, belowSubview: cardScrollView)
		costView.translatesAutoresizingMaskIntoConstraints = false
		
		costView.topAnchor.constraint(equalTo: cardLayoutGuide.bottomAnchor, constant: cardBottomPadding).isActive = true
		costView.rightAnchor.constraint(equalTo: cardLayoutGuide.rightAnchor, constant: -10).isActive = true
		
		// Content under the card
		insertSubview(underView, belowSubview: cardScrollView)
		underView.translatesAutoresizingMaskIntoConstraints = false
		underView.bottomAnchor.constraint(equalTo: cardLayoutGuide.bottomAnchor).isActive = true
		underView.topAnchor.constraint(equalTo: cardLayoutGuide.topAnchor).isActive = true
		underView.leftAnchor.constraint(equalTo: cardLayoutGuide.leftAnchor).isActive = true
		underView.rightAnchor.constraint(equalTo: cardLayoutGuide.rightAnchor).isActive = true
		
		// Ship size
		shipSizeLabel.textAlignment = .center
		shipSizeLabel.textColor = UIColor.white.withAlphaComponent(0.5)
		shipSizeLabel.font = UIFont.xWingIcon(24)
		shipSizeLabel.translatesAutoresizingMaskIntoConstraints = false
		
		underView.addSubview(shipSizeLabel)
		shipSizeLabel.bottomAnchor.constraint(equalTo: underView.bottomAnchor, constant: -10).isActive = true
		shipSizeLabel.rightAnchor.constraint(equalTo: underView.rightAnchor, constant: -10).isActive = true
		
		// Hyperspace label
		hyperspaceLabel.textColor = UIColor.white.withAlphaComponent(0.5)
		hyperspaceLabel.font = UIFont.systemFont(ofSize: 12)
		hyperspaceLabel.text = "H"
		hyperspaceLabel.translatesAutoresizingMaskIntoConstraints = false
		
		underView.addSubview(hyperspaceLabel)
		hyperspaceLabel.rightAnchor.constraint(equalTo: underView.rightAnchor, constant: -10).isActive = true
		hyperspaceLabel.bottomAnchor.constraint(equalTo: shipSizeLabel.topAnchor,  constant: -10).isActive = true
		
		// Dial
		underView.addSubview(dialView)
		dialView.bottomAnchor.constraint(equalTo: underView.bottomAnchor).isActive = true
		dialView.leftAnchor.constraint(equalTo: underView.leftAnchor, constant: 10).isActive = true
		
		// Upgrade slots
		upgradeSlotsBar.translatesAutoresizingMaskIntoConstraints = false
		insertSubview(upgradeSlotsBar, belowSubview: cardScrollView)
		
		upgradeSlotsBar.topAnchor.constraint(equalTo: cardLayoutGuide.bottomAnchor, constant: cardBottomPadding).isActive = true
		upgradeSlotsBar.leftAnchor.constraint(equalTo: cardLayoutGuide.leftAnchor, constant: -CardDetailsCollectionViewCell.horizontalPadding).isActive = true
		upgradeSlotsBar.rightAnchor.constraint(equalTo: costView.leftAnchor, constant: -10).isActive = true
		
		// Flip button
		flipButton.setTitle("Flip", for: .normal)
		insertSubview(flipButton, belowSubview: cardScrollView)
		flipButton.translatesAutoresizingMaskIntoConstraints = false
		flipButton.topAnchor.constraint(equalTo: cardLayoutGuide.bottomAnchor, constant: cardBottomPadding).isActive = true
		flipButton.leftAnchor.constraint(equalTo: cardLayoutGuide.leftAnchor, constant: 10).isActive = true
		
		flipButton.addTarget(self, action: #selector(flipCard), for: .touchUpInside)
		
		// Unreleased button
		unreleasedLabel.textColor = UIColor.white.withAlphaComponent(0.5)
		unreleasedLabel.text = "Unreleased"
		
		insertSubview(unreleasedLabel, belowSubview: cardScrollView)
		unreleasedLabel.translatesAutoresizingMaskIntoConstraints = false
		
		unreleasedLabel.topAnchor.constraint(equalTo: cardLayoutGuide.bottomAnchor, constant: cardBottomPadding).isActive = true
		unreleasedLabel.rightAnchor.constraint(equalTo: cardLayoutGuide.rightAnchor, constant: -10).isActive = true
	}
	
	required init?(coder aDecoder: NSCoder) {
		fatalError()
	}
	
	@objc func flipCard() {
		cardView.flip()
	}
	
	@objc func squadButtonPressed() {
		delegate?.didPressSquadButton(for: self)
	}
	
}
