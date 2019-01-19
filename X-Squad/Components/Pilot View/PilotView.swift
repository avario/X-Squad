//
//  SquadPilotView.swift
//  X-Squad
//
//  Created by Avario on 11/01/2019.
//  Copyright © 2019 Avario. All rights reserved.
//

import Foundation
import UIKit

protocol PilotViewDelegate: AnyObject {
	func pilotView(_ pilotView: PilotView, didSelect pilot: Squad.Pilot)
	func pilotView(_ pilotView: PilotView, didSelect upgrade: Squad.Pilot.Upgrade)
	func pilotView(_ pilotView: PilotView, didPress button: UpgradeButton)
}

class PilotView: UIView {
	
	weak var delegate: PilotViewDelegate?
	
	let pilot: Squad.Pilot
	private let pilotCardView = CardView()
	
	private var upgradeButtons: [UpgradeButton] = []
	private var cardViews: [CardView] = []
	
	let isEditing: Bool
	
	private var widthConstraint: NSLayoutConstraint! = nil
	
	init(pilot: Squad.Pilot, height: CGFloat, isEditing: Bool = true) {
		self.pilot = pilot
		self.isEditing = isEditing
		
		super.init(frame: CGRect(origin: .zero, size: CGSize(width: 0, height: height)))
		self.translatesAutoresizingMaskIntoConstraints = false
		self.heightAnchor.constraint(equalToConstant: height).isActive = true
		
		widthConstraint = self.widthAnchor.constraint(equalToConstant: 0)
		widthConstraint.isActive = true
		
		clipsToBounds = false
		
		pilotCardView.card = pilot.card
		pilotCardView.id = pilot.uuid.uuidString
		addSubview(pilotCardView)
		
		let cardTapGesture = UITapGestureRecognizer(target: self, action: #selector(selectCard(tapGesture:)))
		pilotCardView.addGestureRecognizer(cardTapGesture)
		
		NotificationCenter.default.addObserver(self, selector: #selector(updatePilot), name: .squadStoreDidAddUpgradeToPilot, object: pilot)
		NotificationCenter.default.addObserver(self, selector: #selector(updatePilot), name: .squadStoreDidRemoveUpgradeFromPilot, object: pilot)
	}
	
	required init?(coder aDecoder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
	@objc func addUpgrade(button: UpgradeButton) {
		delegate?.pilotView(self, didPress: button)
	}
	
	@objc func selectCard(tapGesture: UITapGestureRecognizer) {
		guard let cardView = tapGesture.view as? CardView,
			let card = cardView.card else {
				return
		}
		
		switch card.type {
		case .pilot:
			delegate?.pilotView(self, didSelect: pilot)
		case .upgrade:
			guard let upgrade = pilot.upgrades.first(where: { $0.uuid.uuidString == cardView.id }) else {
				return
			}
			delegate?.pilotView(self, didSelect: upgrade)
		}
	}
	
	override func didMoveToSuperview() {
		super.didMoveToSuperview()
		
		updatePilot()
	}
	
	@objc func updatePilot() {
		if isEditing {
			for upgradeButton in self.upgradeButtons {
				upgradeButton.removeFromSuperview()
			}
			self.upgradeButtons.removeAll()
			
			for upgrade in pilot.allUpgradeSlots {
				let upgradeButton = UpgradeButton(frame: CGRect(origin: .zero, size: CGSize(width: 44, height: 44)))
				upgradeButton.upgradeType = upgrade
				
				insertSubview(upgradeButton, at: 0)
				self.upgradeButtons.append(upgradeButton)
				
				upgradeButton.addTarget(self, action: #selector(addUpgrade(button:)), for: .touchUpInside)
			}
		}
		
		// Constants
		let pilotCardTopPadding: CGFloat = 10
		let cardLength: CGFloat = bounds.height - pilotCardTopPadding * 2
		let cardWidth: CGFloat = cardLength / CardView.sizeRatio
		let upgradeCardTopPadding: CGFloat = pilotCardTopPadding + cardLength * 0.08
		
		var leadingEdge: CGFloat = 0
		
		// Remove any card views for upgrades that are no longer equipped
		for cardView in cardViews {
			if let card = cardView.card,
				card.type == .upgrade,
				!pilot.upgrades.contains(where: { $0.card == card }) {
				cardView.removeFromSuperview()
			}
		}
		cardViews = cardViews.filter({ $0.superview != nil })
		
		// Keep track of which buttons are not associated with an equipped upgrade
		var availableUpgradeButtons = self.upgradeButtons
		
		// Return the upgrade button for the upgrade and remove it from the available upgrade buttons
		func upgradeButtons(for upgrade: Squad.Pilot.Upgrade) -> [UpgradeButton] {
			var upgradeButtons: [UpgradeButton] = []
			for upgradeType in upgrade.card.upgradeTypes {
				guard let upgradeButton = availableUpgradeButtons.first(where: { $0.upgradeType == upgradeType }) else {
					continue
				}
				upgradeButtons.append(upgradeButton)
				
				let index = availableUpgradeButtons.firstIndex(of: upgradeButton)!
				availableUpgradeButtons.remove(at: index)
				upgradeButton.associatedUpgrade = upgrade
			}
			
			return upgradeButtons
		}
		
		// Return the existing card view for the upgrade or create a new card view
		func cardView(for upgrade: Squad.Pilot.Upgrade) -> CardView {
			if let existingCardView = cardViews.first(where: { $0.id == upgrade.uuid.uuidString }) {
				return existingCardView
			} else {
				let cardView = CardView()
				cardView.card = upgrade.card
				cardView.id = upgrade.uuid.uuidString
				
				let cardTapGesture = UITapGestureRecognizer(target: self, action: #selector(selectCard(tapGesture:)))
				cardView.addGestureRecognizer(cardTapGesture)
				
				insertSubview(cardView, belowSubview: pilotCardView)
				cardViews.append(cardView)
				
				return cardView
			}
		}
		
		// Position the configuration card to the left of the pilot
		if let configuration = pilot.upgrades.first(where: { $0.card.upgradeTypes.contains(Card.UpgradeType.configuration) }) {
			let configurationCardView = cardView(for: configuration)
			
			configurationCardView.frame = CGRect(
				origin: CGPoint(x: leadingEdge, y: upgradeCardTopPadding),
				size: CGSize(width: cardLength, height: cardWidth))
			
			leadingEdge = configurationCardView.frame.maxX - cardLength * CardView.upgradeHiddenRatio
			
			if let upgradeButton = upgradeButtons(for: configuration).first {
				upgradeButton.frame = CGRect(
					origin: CGPoint(x: leadingEdge - 10 - upgradeButton.bounds.width, y: configurationCardView.frame.maxY),
					size: upgradeButton.bounds.size)
			}
		}
		
		// Position the pilot card
		pilotCardView.frame = CGRect(
			origin: CGPoint(x: leadingEdge, y: pilotCardTopPadding),
			size: CGSize(width: cardWidth, height: cardLength))

		leadingEdge = pilotCardView.frame.maxX
		
		// Keep track of the previous card view so that following cards can be placed below it
		var previousCardView = pilotCardView
		
		for upgrade in pilot.upgrades {
			guard upgrade.card.upgradeTypes.contains(.configuration) == false else {
				continue
			}
			
			let upgradeCardView = cardView(for: upgrade)
			
			upgradeCardView.frame = CGRect(
				origin: CGPoint(x: leadingEdge - cardLength * CardView.upgradeHiddenRatio, y: upgradeCardTopPadding),
				size: CGSize(width: cardLength, height: cardWidth))
			
			insertSubview(upgradeCardView, belowSubview: previousCardView)
			
			for (index, upgradeButton) in upgradeButtons(for: upgrade).enumerated() {
				upgradeButton.frame = CGRect(
					origin: CGPoint(x: leadingEdge + 10 + CGFloat(index) * (upgradeButton.bounds.width), y: upgradeCardView.frame.maxY),
					size: upgradeButton.bounds.size)
			}
			
			leadingEdge = upgradeCardView.frame.maxX
			previousCardView = upgradeCardView
		}
		
		// Any buttons that weren't used by an upgrade should be positioned at the end of the list
		for upgradeButton in availableUpgradeButtons {
			upgradeButton.frame = CGRect(
				origin: CGPoint(x: leadingEdge, y: upgradeCardTopPadding + cardWidth),
				size: upgradeButton.bounds.size)
			leadingEdge = upgradeButton.frame.maxX
			
			upgradeButton.associatedUpgrade = nil
		}
		
		widthConstraint.constant = leadingEdge
	}
	
}
