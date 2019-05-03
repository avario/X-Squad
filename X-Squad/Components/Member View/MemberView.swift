//
//  MemberView.swift
//  X-Squad
//
//  Created by Avario on 11/01/2019.
//  Copyright © 2019 Avario. All rights reserved.
//
// This is the view that lays out a pilot card horizontally with all of its upgrade cards.

import Foundation
import UIKit

protocol MemberViewDelegate: AnyObject {
	func memberView(_ memberView: MemberView, didSelect pilot: Pilot)
	func memberView(_ memberView: MemberView, didSelect upgrade: Upgrade)
	func memberView(_ memberView: MemberView, didPress button: UpgradeButton)
}

class MemberView: UIView, CardDetailsCollectionViewControllerDataSource, CardDetailsCollectionViewControllerDelegate {
	
	weak var delegate: MemberViewDelegate?
	
	let member: Squad.Member
	
	private let pilotCardView = CardView()
	private var upgradeButtons: [UpgradeButton] = []
	private(set) var cardViews: [CardView] = []
	
	enum Mode {
		case display
		case edit
		case game
	}
	
	let mode: Mode
	
	var widthConstraint: NSLayoutConstraint! = nil
	
	init(member: Squad.Member, height: CGFloat, mode: Mode = .display) {
		self.member = member
		self.mode = mode
		
		super.init(frame: CGRect(origin: .zero, size: CGSize(width: 0, height: height)))
		self.translatesAutoresizingMaskIntoConstraints = false
		self.heightAnchor.constraint(equalToConstant: height).isActive = true
		
		widthConstraint = self.widthAnchor.constraint(equalToConstant: 0)
		widthConstraint.isActive = true
		
		clipsToBounds = false
		
		pilotCardView.card = member.pilot
		pilotCardView.member = member
		addSubview(pilotCardView)
		
		cardViews.append(pilotCardView)
		
		let cardTapGesture = UITapGestureRecognizer(target: self, action: #selector(selectCard(tapGesture:)))
		pilotCardView.addGestureRecognizer(cardTapGesture)
		
		// This view updates itself from notifications from the Squad Store.
		NotificationCenter.default.addObserver(self, selector: #selector(updatePilot), name: .squadStoreDidAddUpgradeToMember, object: member)
		NotificationCenter.default.addObserver(self, selector: #selector(updatePilot), name: .squadStoreDidRemoveUpgradeFromMember, object: member)
	}
	
	required init?(coder aDecoder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
	@objc func addUpgrade(button: UpgradeButton) {
		delegate?.memberView(self, didPress: button)
	}
	
	@objc func selectCard(tapGesture: UITapGestureRecognizer) {
		guard let cardView = tapGesture.view as? CardView,
			let card = cardView.card else {
				return
		}
		
		switch card {
		case let pilot as Pilot:
			delegate?.memberView(self, didSelect: pilot)
		case let upgrade as Upgrade:
			delegate?.memberView(self, didSelect: upgrade)
		default:
			fatalError()
		}
	}
	
	override func didMoveToSuperview() {
		super.didMoveToSuperview()
		updatePilot()
	}
	
	// This adds and lays out the card images and buttons.
	@objc func updatePilot() {
		// Constants
		let pilotCardTopPadding: CGFloat = 10
		let cardLength: CGFloat = bounds.height - pilotCardTopPadding * 2
		let cardWidth: CGFloat = cardLength / CardView.sizeRatio
		let upgradeCardTopPadding: CGFloat = pilotCardTopPadding + cardLength * 0.08
		let upgradeButtonSize: CGFloat = 44
		
		var leadingEdge: CGFloat = 0
		
		if mode == .edit {
			// Only show upgrade slot buttons in the edit mode.
			for upgradeButton in self.upgradeButtons {
				upgradeButton.removeFromSuperview()
			}
			self.upgradeButtons.removeAll()
			
			for upgrade in member.allSlots.sorted(by: { $0.priority.rawValue < $1.priority.rawValue }) {
				let upgradeButton = UpgradeButton(frame: CGRect(origin: .zero, size: CGSize(width: upgradeButtonSize, height: upgradeButtonSize)))
				upgradeButton.upgradeType = upgrade
				
				insertSubview(upgradeButton, at: 0)
				self.upgradeButtons.append(upgradeButton)
				
				upgradeButton.addTarget(self, action: #selector(addUpgrade(button:)), for: .touchUpInside)
			}
		}
		
		// Remove any card views for upgrades that are no longer equipped
		for cardView in cardViews {
			if let upgrade = cardView.card as? Upgrade,
				!member.upgrades.contains(upgrade) {
				cardView.removeFromSuperview()
			}
		}
		cardViews = cardViews.filter({ $0.superview != nil })
		
		// Keep track of which buttons are not associated with an equipped upgrade
		var availableUpgradeButtons = self.upgradeButtons
		
		// Return the upgrade button for the upgrade and remove it from the available upgrade buttons
		func upgradeButtons(for upgrade: Upgrade) -> [UpgradeButton] {
			var upgradeButtons: [UpgradeButton] = []
			for upgradeType in upgrade.frontSide.slots {
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
		func cardView(for upgrade: Upgrade) -> CardView {
			if let existingCardView = cardViews.first(where: {
				if let card = $0.card as? Upgrade, card == upgrade {
					return true
				} else {
					return false
				}
			}) {
				return existingCardView
			} else {
				let cardView = CardView()
				cardView.card = upgrade
				cardView.member = member
				
				let cardTapGesture = UITapGestureRecognizer(target: self, action: #selector(selectCard(tapGesture:)))
				cardView.addGestureRecognizer(cardTapGesture)
				
				insertSubview(cardView, belowSubview: pilotCardView)
				cardViews.append(cardView)
				
				return cardView
			}
		}
		
		// Position the configuration card to the left of the pilot
		if let configuration = member.upgrades.first(where: { $0.frontSide.type == .configuration }) {
			let configurationCardView = cardView(for: configuration)
			
			configurationCardView.frame = CGRect(
				origin: CGPoint(x: leadingEdge, y: upgradeCardTopPadding),
				size: CGSize(width: cardLength, height: cardWidth))
			
			leadingEdge = configurationCardView.frame.maxX - cardLength * CardView.upgradeHiddenRatio
			
			for (index, upgradeButton) in upgradeButtons(for: configuration).enumerated() {
				upgradeButton.frame = CGRect(
					origin: CGPoint(x: leadingEdge - 10 - CGFloat(index + 1) * upgradeButton.bounds.width, y: configurationCardView.frame.maxY),
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
		
		for upgrade in member.upgrades {
			guard upgrade.frontSide.type != .configuration else {
				continue
			}
			
			let upgradeCardView = cardView(for: upgrade)
			
			upgradeCardView.frame = CGRect(
				origin: CGPoint(x: leadingEdge - cardLength * CardView.upgradeHiddenRatio, y: upgradeCardTopPadding),
				size: CGSize(width: cardLength, height: cardWidth))
			
			insertSubview(upgradeCardView, belowSubview: previousCardView)
			
			for (index, upgradeButton) in upgradeButtons(for: upgrade).enumerated() {
				upgradeButton.frame = CGRect(
					origin: CGPoint(x: leadingEdge + 10 + CGFloat(index) * upgradeButton.bounds.width, y: upgradeCardView.frame.maxY),
					size: upgradeButton.bounds.size)
			}
			
			leadingEdge = upgradeCardView.frame.maxX
			previousCardView = upgradeCardView
		}
		
		// Any buttons that weren't used by an upgrade should be positioned at the end of the list
		if mode == .edit, availableUpgradeButtons.isEmpty == false {
			let buttonsInColumn = 4
			let leftSpacing: CGFloat = 10
			
			for (index, upgradeButton) in availableUpgradeButtons.enumerated() {
				let column = floor(Double(index)/Double(buttonsInColumn))
				let row = index % buttonsInColumn
				
				upgradeButton.frame = CGRect(
					origin: CGPoint(x: leadingEdge + leftSpacing + upgradeButton.frame.width * CGFloat(column), y: upgradeCardTopPadding + upgradeButton.frame.height * CGFloat(row)),
					size: upgradeButton.bounds.size)
				upgradeButton.associatedUpgrade = nil
			}
			
			let numberOfColumns = ceil(Double(availableUpgradeButtons.count)/Double(buttonsInColumn))
			leadingEdge += leftSpacing + upgradeButtonSize * CGFloat(numberOfColumns)
		}
		
		widthConstraint.constant = leadingEdge
	}
	
	var cards: [Card] {
		return [member.pilot] + member.upgrades
	}
	
	func member(for card: Card) -> Squad.Member? {
		return member
	}
	
	func squadAction(for card: Card) -> SquadButton.Action? {
		guard mode == .edit else {
			return nil
		}
		
		switch card {
		case _ as Pilot:
			return .remove("Remove from Squad")
		case _ as Upgrade:
			return .remove("Remove from Pilot")
		default:
			fatalError()
		}
	}
	
	func cost(for card: Card) -> Int {
		return card.pointCost(for: member)
	}
	
	func cardDetailsCollectionViewController(_ cardDetailsCollectionViewController: CardDetailsCollectionViewController, didPressSquadButtonFor card: Card) {
		let squad = member.squad
		
		switch card {
		case _ as Pilot:
			squad.remove(member: member)
		case let upgrade as Upgrade:
			member.removeUpgrade(upgrade)
		default:
			fatalError()
		}
		
		cardDetailsCollectionViewController.dismiss(animated: true, completion: nil)
	}
	
	func cardDetailsCollectionViewController(_ cardDetailsCollectionViewController: CardDetailsCollectionViewController, didChangeFocusFrom fromCard: Card, to toCard: Card) {
		for cardView in cardViews {
			cardView.isHidden = cardView.card?.matches(toCard) ?? false
		}
	}
}
