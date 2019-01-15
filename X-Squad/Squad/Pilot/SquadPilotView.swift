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
	func squadPilotView(_ squadPilotView: SquadPilotView, didPress button: UpgradeButton)
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
		
		clipsToBounds = false
		scrollView.clipsToBounds = false
		
		addSubview(scrollView)
		scrollView.translatesAutoresizingMaskIntoConstraints = false
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
		
		for upgrade in pilot.card?.availableUpgrades ?? [] {
			let upgradeButton = UpgradeButton(frame: CGRect(origin: .zero, size: CGSize(width: 44, height: 44)))
			upgradeButton.upgradeType = upgrade
			
			scrollView.insertSubview(upgradeButton, at: 0)
			upgradeButtons.append(upgradeButton)
			
			upgradeButton.addTarget(self, action: #selector(addUpgrade(button:)), for: .touchUpInside)
		}
	}
	
	required init?(coder aDecoder: NSCoder) {
		fatalError()
	}
	
	@objc func addUpgrade(button: UpgradeButton) {
		delegate?.squadPilotView(self, didPress: button)
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
	
	override func didMoveToSuperview() {
		super.didMoveToSuperview()
		
		updateSquad()
	}
	
	func updateSquad() {
		let scrollViewHorizontalPadding: CGFloat = 16
		let upgradeCardTopPadding: CGFloat = 30
		
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
				origin: CGPoint(x: leadingEdge, y: upgradeCardTopPadding),
				size: CGSize(width: cardLength, height: cardWidth))
			
			scrollView.insertSubview(configurationCardView, belowSubview: pilotCardView)
			configurationCardView.snap.snapPoint = scrollView.convert(configurationCardView.center, to: nil)
			
			leadingEdge = configurationCardView.frame.maxX - cardLength * CardView.upgradeHiddenRatio
			
			if let configurationButton = availableUpgradeButtons.first(where: { $0.upgradeType == Card.UpgradeType.configuration }) {
				configurationButton.frame = CGRect(
					origin: CGPoint(x: leadingEdge - 10 - configurationButton.bounds.width, y: configurationCardView.frame.maxY),
					size: configurationButton.bounds.size)
				
				let index = availableUpgradeButtons.firstIndex(of: configurationButton)!
				availableUpgradeButtons.remove(at: index)
				configurationButton.associatedUpgrade = configuration
			}
		}
		
		pilotCardView.frame = CGRect(
			origin: CGPoint(x: leadingEdge, y: 10),
			size: CGSize(width: cardWidth, height: cardLength))
		pilotCardView.snap.snapPoint = scrollView.convert(pilotCardView.center, to: nil)
		
		leadingEdge = pilotCardView.frame.maxX
		
		var previousCardView = pilotCardView
		
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
				origin: CGPoint(x: leadingEdge - cardLength * CardView.upgradeHiddenRatio, y: upgradeCardTopPadding),
				size: CGSize(width: cardLength, height: cardWidth))
			
			scrollView.insertSubview(upgradeCardView, belowSubview: previousCardView)
			upgradeCardView.snap.snapPoint = scrollView.convert(upgradeCardView.center, to: nil)
			
			var upgradeButtons: [UpgradeButton] = []
			for upgradeType in upgrade.card!.upgradeTypes {
				guard let upgradeButton = availableUpgradeButtons.first(where: { $0.upgradeType == upgradeType }) else {
					continue
				}
				upgradeButtons.append(upgradeButton)
				
				let index = availableUpgradeButtons.firstIndex(of: upgradeButton)!
				availableUpgradeButtons.remove(at: index)
				upgradeButton.associatedUpgrade = upgrade
			}
			
			for (index, upgradeButton) in upgradeButtons.enumerated() {
				upgradeButton.frame = CGRect(
					origin: CGPoint(x: leadingEdge + 10 + CGFloat(index) * (upgradeButton.bounds.width), y: upgradeCardView.frame.maxY),
					size: upgradeButton.bounds.size)
			}
			
			leadingEdge = upgradeCardView.frame.maxX
			previousCardView = upgradeCardView
		}
		
		for upgradeButton in availableUpgradeButtons {
			upgradeButton.frame = CGRect(
				origin: CGPoint(x: leadingEdge, y: upgradeCardTopPadding + cardWidth + 5),
				size: upgradeButton.bounds.size)
			leadingEdge = upgradeButton.frame.maxX
			
			upgradeButton.associatedUpgrade = nil
		}
		
		scrollView.contentSize = CGSize(width: leadingEdge + scrollViewHorizontalPadding, height: scrollView.bounds.height)
	}
	
}
