//
//  SquadCell.swift
//  X-Squad
//
//  Created by Avario on 10/01/2019.
//  Copyright © 2019 Avario. All rights reserved.
//

import Foundation
import UIKit

class SquadCell: UITableViewCell {
	
	static let reuseIdentifier = "SquadCell"
	
	var squad: Squad? {
		didSet {
			guard let squad = squad else {
				return
			}
			
			iconLabel.text = squad.faction.characterCode
			
			layoutSquadCards()
		}
	}
	
	let iconLabel = UILabel()
	let scrollView = UIScrollView()
	
	override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
		super.init(style: style, reuseIdentifier: reuseIdentifier)
		
		backgroundColor = .black
		contentView.backgroundColor = .clear
		
		let backgroundView = UIView()
		backgroundView.backgroundColor = UIColor.init(white: 0.20, alpha: 1.0)
		selectedBackgroundView = backgroundView
		
		contentView.addSubview(scrollView)
		scrollView.translatesAutoresizingMaskIntoConstraints = false
		scrollView.alwaysBounceHorizontal = true
		scrollView.isUserInteractionEnabled = false
		contentView.addGestureRecognizer(scrollView.panGestureRecognizer)
		
		scrollView.topAnchor.constraint(equalTo: contentView.topAnchor).isActive = true
		scrollView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor).isActive = true
		scrollView.leftAnchor.constraint(equalTo: contentView.leftAnchor).isActive = true
		scrollView.rightAnchor.constraint(equalTo: contentView.rightAnchor).isActive = true
		
		scrollView.addSubview(iconLabel)
		iconLabel.textAlignment = .center
		iconLabel.translatesAutoresizingMaskIntoConstraints = false
		iconLabel.textColor = UIColor.white.withAlphaComponent(0.5)
		iconLabel.font = UIFont.xWingIcon(32)
		
		iconLabel.leftAnchor.constraint(equalTo: scrollView.leftAnchor).isActive = true
		iconLabel.centerYAnchor.constraint(equalTo: scrollView.centerYAnchor).isActive = true
		iconLabel.widthAnchor.constraint(equalToConstant: 44).isActive = true
		iconLabel.heightAnchor.constraint(equalToConstant: 44).isActive = true
	}
	
	required init?(coder aDecoder: NSCoder) {
		fatalError()
	}
	
	var squadCardViews: [CardView] = []
	
	func layoutSquadCards() {
		for squadCardView in squadCardViews {
			squadCardView.removeFromSuperview()
		}
		
		squadCardViews.removeAll()
		
		guard let squad = squad else {
			return
		}
		
		let cardLength: CGFloat = 60
		let cardWidth: CGFloat = cardLength/CardView.sizeRatio
		var leadingEdge: CGFloat = 44
		
		for pilot in squad.pilots.value {
			if let configuration = pilot.upgrades.value.first(where: { $0.card?.upgradeTypes.contains(Card.UpgradeType.configuration) ?? false }) {
				let configurationCardView = CardView()
				configurationCardView.card = configuration.card
				configurationCardView.id = configuration.uuid.uuidString
				
				configurationCardView.frame = CGRect(
					origin: CGPoint(x: leadingEdge, y: 15),
					size: CGSize(width: cardLength, height: cardWidth))
				
				scrollView.insertSubview(configurationCardView, at: 0)
				
				leadingEdge = configurationCardView.frame.maxX - cardLength * CardView.upgradeHiddenRatio
			}
			
			let pilotCardView = CardView()
			pilotCardView.card = pilot.card
			pilotCardView.id = pilot.uuid.uuidString
			
			pilotCardView.frame = CGRect(
				origin: CGPoint(x: leadingEdge, y: 10),
				size: CGSize(width: cardWidth, height: cardLength))
			
			scrollView.addSubview(pilotCardView)
			
			leadingEdge = pilotCardView.frame.maxX
			
			for upgrade in pilot.upgrades.value {
				guard upgrade.card?.upgradeTypes.contains(.configuration) == false else {
					continue
				}
				
				let upgradeCardView = CardView()
				upgradeCardView.card = upgrade.card
				upgradeCardView.id = upgrade.uuid.uuidString
				
				upgradeCardView.frame = CGRect(
					origin: CGPoint(x: leadingEdge - cardLength * CardView.upgradeHiddenRatio, y: 15),
					size: CGSize(width: cardLength, height: cardWidth))
		
				scrollView.insertSubview(upgradeCardView, at: 0)
				
				leadingEdge = upgradeCardView.frame.maxX
			}
			
			leadingEdge += 10
		}
		
		scrollView.contentSize = CGSize(width: leadingEdge, height: scrollView.bounds.height)
	}
	
}
