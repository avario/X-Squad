//
//  AddUpgradeViewController.swift
//  X-Squad
//
//  Created by Avario on 13/01/2019.
//  Copyright © 2019 Avario. All rights reserved.
//

import Foundation
import UIKit

class AddUpgradeViewController: CardsViewController {
	
	let squad: Squad
	let pilot: Squad.Pilot
	let upgradeType: Card.UpgradeType
	
	init(squad: Squad, pilot: Squad.Pilot, upgradeType: Card.UpgradeType) {
		self.squad = squad
		self.pilot = pilot
		self.upgradeType = upgradeType
		
		super.init(numberOfColumns: 3)
		
		var upgrades: [Card] = []
		var invalidUpgrades: [Card] = []
		for card in CardStore.cards {
			guard card.type == .upgrade,
				card.upgradeTypes.contains(upgradeType) else {
					continue
			}
			
			if card.isValid(in: squad, for: pilot) {
				upgrades.append(card)
			} else {
				invalidUpgrades.append(card)
			}
		}
		
		cardSections.append(
			CardSection(
				header: .header(
					CardSection.HeaderInfo(
						title: "",
						icon: upgradeType.characterCode,
						iconFont: UIFont.xWingIcon(32)
					)
				),
				cards: upgrades.sorted {
					if $0.pointCost == $1.pointCost {
						return $0.name < $1.name
					}
					return $0.pointCost > $1.pointCost
				}
			)
		)
		
		cardSections.append(
			CardSection(
				header: .header(
					CardSection.HeaderInfo(
						title: "",
						icon: "",
						iconFont: UIFont.xWingIcon(32)
					)
				),
				cards: invalidUpgrades.sorted {
					if $0.pointCost == $1.pointCost {
						return $0.name < $1.name
					}
					return $0.pointCost > $1.pointCost
				}
			)
		)
	}
	
	required init?(coder aDecoder: NSCoder) {
		fatalError()
	}
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		let panGesture = UIPanGestureRecognizer(target: self, action: #selector(panCards(recognizer:)))
		panGesture.maximumNumberOfTouches = 1
		panGesture.delegate = self
		collectionView.addGestureRecognizer(panGesture)
	}
	
	@objc func panCards(recognizer: UIPanGestureRecognizer) {
		switch recognizer.state {
		case .began:
			break
			
		case .changed:
			break
			
		case .cancelled, .ended, .failed:
			let velocity = recognizer.velocity(in: view)
			if velocity.y > 500 {
				dismiss(animated: true, completion: nil)
			}
		case.possible:
			break
		}
	}
	
	override func cardViewController(_ cardViewController: CardViewController, didSelect card: Card) {
		let upgrade = Squad.Pilot.Upgrade(card: card)
		pilot.upgrades.value.append(upgrade)
		SquadStore.save()
		presentingViewController?.dismiss(animated: true, completion: nil)
	}
	
	override func isCardAvailable(_ card: Card, at index: IndexPath) -> Bool {
		if index.section > 0 {
			return false
		}
		
		if card.isUnique {
			for pilot in squad.pilots.value {
				if pilot.card?.name == card.name || pilot.upgrades.value.contains(where: { $0.card?.name == card.name }) {
					return false
				}
			}
		}
		
		return true
	}
	
}

extension AddUpgradeViewController: UIGestureRecognizerDelegate {
	
	func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
		guard let panGesture = gestureRecognizer as? UIPanGestureRecognizer else {
			return true
		}
		
		if collectionView.contentOffset.y <= -collectionView.adjustedContentInset.top,
			panGesture.velocity(in: nil).y >= 0 {
			return true
		}
		
		// Scroll as normal
		return false
	}
	
	func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
		return true
	}
	
}

extension Card {
	
	func isValid(in squad: Squad, for pilot: Squad.Pilot) -> Bool {
		guard let pilotCard = pilot.card else {
			return false
		}
		
		for restrictionSet in restrictions {
			var passedSet = false
			
			for restriction in restrictionSet {
				switch restriction.type {
				case .faction:
					if let factionID = restriction.parameters.id,
						squad.faction.rawValue == factionID {
						passedSet = true
					}
					
				case .action:
					if let actionID = restriction.parameters.id,
						let action = pilotCard.availableActions.first(where: { $0.baseType.rawValue == actionID }) {
						if let sideEffect = restriction.parameters.sideEffectName {
							switch sideEffect {
							case .stress:
								if action.baseSideEffect == .stress {
									passedSet = true
								}
							case .none:
								if action.baseSideEffect == nil {
									passedSet = true
								}
							}
						} else {
							passedSet = true
						}
					}
					
				case .shipType:
					if let shipID = restriction.parameters.id,
						pilotCard.shipType?.rawValue == shipID {
						passedSet = true
					}
					
				case .shipSize:
					if let shipSize = restriction.parameters.shipSizeName {
						switch shipSize {
						case .small:
							if pilotCard.shipSize == .small {
								passedSet = true
							}
						case .medium:
							if pilotCard.shipSize == .medium {
								passedSet = true
							}
						case .large:
							if pilotCard.shipSize == .large {
								passedSet = true
							}
						}
					}
					
				case .cardIncluded:
					if let cardID = restriction.parameters.id {
						for pilot in squad.pilots.value {
							if pilot.cardID == cardID ||
								pilot.upgrades.value.contains(where: { $0.cardID == cardID }) {
								passedSet = true
								break
							}
						}
					}
					
				case .arc:
					if let arcID = restriction.parameters.id,
						pilotCard.statistics.contains(where: { $0.type.rawValue == arcID }) {
						passedSet = true
					}
					
				case .forceSide:
					if let forceSide = restriction.parameters.forceSideName {
						switch forceSide {
						case .light:
							if pilotCard.forceSide == .light {
								passedSet = true
							}
						case .dark:
							if pilotCard.forceSide == .dark {
								passedSet = true
							}
						}
					}
				}
				
				if passedSet { break }
			}
			
			guard passedSet else { return false }
		}
		return true
	}
	
}
