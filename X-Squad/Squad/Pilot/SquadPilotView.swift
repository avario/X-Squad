//
//  SquadPilotView.swift
//  X-Squad
//
//  Created by Avario on 11/01/2019.
//  Copyright © 2019 Avario. All rights reserved.
//

import Foundation
import UIKit

protocol SquadPilotViewDelegate: AnyObject {
	func squadPilotView(_ squadPilotView: SquadPilotView, didSelect pilot: Squad.Pilot)
	func squadPilotView(_ squadPilotView: SquadPilotView, didSelect upgrade: Squad.Pilot.Upgrade)
	func squadPilotView(_ squadPilotView: SquadPilotView, didPressButtonFor upgradeType: Card.UpgradeType)
}

class SquadPilotView: UIView {
	
	weak var delegate: SquadPilotViewDelegate?
	
	let scrollView = UIScrollView()
	
	let pilot: Squad.Pilot
	let pilotCardView = CardView()
	
	var upgradeButtons: [UpgradeButton] = []
	
	init(pilot: Squad.Pilot) {
		self.pilot = pilot
		
		let width = UIScreen.main.bounds.width
		let height = width * 0.75
		
		super.init(frame: CGRect(origin: .zero, size: CGSize(width: width, height: height)))
		self.translatesAutoresizingMaskIntoConstraints = false
		self.heightAnchor.constraint(equalToConstant: height).isActive = true
		
		addSubview(scrollView)
		scrollView.translatesAutoresizingMaskIntoConstraints = false
		scrollView.delegate = self
		scrollView.alwaysBounceHorizontal = true
		
		scrollView.topAnchor.constraint(equalTo: topAnchor).isActive = true
		scrollView.rightAnchor.constraint(equalTo: rightAnchor).isActive = true
		scrollView.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
		scrollView.leftAnchor.constraint(equalTo: leftAnchor).isActive = true
		
		pilotCardView.card = pilot.card
		pilotCardView.id = pilot.uuid.uuidString
		scrollView.addSubview(pilotCardView)
		
		let cardTapGesture = UITapGestureRecognizer(target: self, action: #selector(selectCard(tapGesture:)))
		pilotCardView.addGestureRecognizer(cardTapGesture)
		
		var upgradeTag = 0
		for upgrade in pilot.card?.availableUpgrades ?? [] {
			let upgradeButton = UpgradeButton(frame: CGRect(origin: .zero, size: CGSize(width: 44, height: 44)))
			upgradeButton.upgrade = upgrade
			upgradeButton.tag = upgradeTag
			
			scrollView.insertSubview(upgradeButton, at: 0)
			upgradeButton.center = CGPoint(x: pilotCardView.frame.maxX + 44 * CGFloat(upgradeTag + 1), y: height/2)
			
			upgradeButtons.append(upgradeButton)
			
			upgradeButton.addTarget(self, action: #selector(addUpgrade(button:)), for: .touchUpInside)
			
			upgradeTag += 1
		}
		
		updateSquad()
	}
	
	required init?(coder aDecoder: NSCoder) {
		fatalError()
	}
	
//	func updateScrollViewContentSize() {
//		var contentWidth = bounds.width/2 + pilotCardView.bounds.width/2
//
//		let rightPadding: CGFloat = 44
//		contentWidth += rightPadding
//
//		if let card = pilot.card {
//			for upgrade in card.availableUpgrades {
//				contentWidth += 44
//			}
//		}
//
//		scrollView.contentSize = CGSize(width: contentWidth, height: 0)
//	}
	
	@objc func addUpgrade(button: UpgradeButton) {
		delegate?.squadPilotView(self, didPressButtonFor: button.upgrade!)
	}
	
	@objc func selectCard(tapGesture: UITapGestureRecognizer) {
		guard let cardView = tapGesture.view as? CardView,
			let card = cardView.card else {
				return
		}
		
		switch card.type {
		case .pilot:
			delegate?.squadPilotView(self, didSelect: pilot)
		case .upgrade:
			guard let upgrade = pilot.upgrades.value.first(where: { $0.uuid.uuidString == cardView.id }) else {
				return
			}
			delegate?.squadPilotView(self, didSelect: upgrade)
		}
	}
	
	func updateSquad() {
		let scrollViewHorizontalPadding: CGFloat = 16
		
		let cardWidth: CGFloat = UIScreen.main.bounds.width * 0.5
		let cardLength: CGFloat = cardWidth * CardView.sizeRatio
		var leadingEdge: CGFloat = scrollViewHorizontalPadding
		
		var availableUpgradeButtons = upgradeButtons
		
		if let configuration = pilot.upgrades.value.first(where: { $0.card?.upgradeTypes.contains(Card.UpgradeType.configuration) ?? false }) {
			let configurationCardView = CardView()
			configurationCardView.card = configuration.card
			configurationCardView.id = configuration.uuid.uuidString
			
			let cardTapGesture = UITapGestureRecognizer(target: self, action: #selector(selectCard(tapGesture:)))
			configurationCardView.addGestureRecognizer(cardTapGesture)
			
			configurationCardView.frame = CGRect(
				origin: CGPoint(x: leadingEdge, y: 20),
				size: CGSize(width: cardLength, height: cardWidth))
			
			scrollView.insertSubview(configurationCardView, at: 0)
			
			leadingEdge = configurationCardView.frame.maxX - cardLength * CardView.upgradeHiddenRatio
			
			if let configurationButton = availableUpgradeButtons.first(where: { $0.upgrade == Card.UpgradeType.configuration }) {
				configurationButton.frame = CGRect(
					origin: CGPoint(x: leadingEdge - 10 - configurationButton.bounds.width, y: configurationCardView.frame.maxY),
					size: configurationButton.bounds.size)
				
				let index = availableUpgradeButtons.firstIndex(of: configurationButton)!
				availableUpgradeButtons.remove(at: index)
			}
		}
		
		pilotCardView.frame = CGRect(
			origin: CGPoint(x: leadingEdge, y: 10),
			size: CGSize(width: cardWidth, height: cardLength))
		
		leadingEdge = pilotCardView.frame.maxX
		
		for upgrade in pilot.upgrades.value {
			guard upgrade.card?.upgradeTypes.contains(.configuration) == false else {
				continue
			}
			
			let upgradeCardView = CardView()
			upgradeCardView.card = upgrade.card
			upgradeCardView.id = upgrade.uuid.uuidString
			
			let cardTapGesture = UITapGestureRecognizer(target: self, action: #selector(selectCard(tapGesture:)))
			upgradeCardView.addGestureRecognizer(cardTapGesture)
			
			upgradeCardView.frame = CGRect(
				origin: CGPoint(x: leadingEdge - cardLength * CardView.upgradeHiddenRatio, y: 20),
				size: CGSize(width: cardLength, height: cardWidth))
			
			scrollView.insertSubview(upgradeCardView, at: 0)
			
			var upgradeButtons: [UpgradeButton] = []
			for upgradeType in upgrade.card!.upgradeTypes {
				guard let upgradeButton = availableUpgradeButtons.first(where: { $0.upgrade == upgradeType }) else {
					continue
				}
				upgradeButtons.append(upgradeButton)
				
				let index = availableUpgradeButtons.firstIndex(of: upgradeButton)!
				availableUpgradeButtons.remove(at: index)
			}
			
			for (index, upgradeButton) in upgradeButtons.enumerated() {
				upgradeButton.frame = CGRect(
					origin: CGPoint(x: leadingEdge + 10 + CGFloat(index) * (upgradeButton.bounds.width), y: upgradeCardView.frame.maxY),
					size: upgradeButton.bounds.size)
			}
			
			leadingEdge = upgradeCardView.frame.maxX
		}
		
		for upgradeButton in availableUpgradeButtons {
			upgradeButton.frame = CGRect(
				origin: CGPoint(x: leadingEdge, y: 20 + cardWidth + 5),
				size: upgradeButton.bounds.size)
			leadingEdge = upgradeButton.frame.maxX
		}
		
		scrollView.contentSize = CGSize(width: leadingEdge + 30, height: scrollView.bounds.height)
	}
	
}

extension SquadPilotView: UIScrollViewDelegate {
	func scrollViewDidScroll(_ scrollView: UIScrollView) {
//		for cardView in cardViews {
//			guard let card = cardView.card else {
//				continue
//			}
//
//			var position = cardPositions[card]!
//			position.x -= scrollView.contentOffset.x
//
////			cardView.snap.snapPoint = position
//			cardView.center = position
//
//			for upgradeButton in upgradeButtons {
//				guard var position = upgradeButtonsPositions[upgradeButton.tag] else {
//					continue
//				}
//				position.x -= scrollView.contentOffset.x
//
//				upgradeButton.center = position
//			}
//		}
	}
}
