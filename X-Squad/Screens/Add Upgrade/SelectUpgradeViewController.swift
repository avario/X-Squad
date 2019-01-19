//
//  SelectUpgradeViewController.swift
//  X-Squad
//
//  Created by Avario on 13/01/2019.
//  Copyright © 2019 Avario. All rights reserved.
//

import Foundation
import UIKit

class SelectUpgradeViewController: CardsViewController {
	
	let squad: Squad
	let pilot: Squad.Pilot
	let currentUpgrade: Squad.Pilot.Upgrade?
	let upgradeType: Card.UpgradeType
	
	var pullToDismissController: PullToDismissController?
	
	let transitionPoint: CGPoint
	
	init(squad: Squad, pilot: Squad.Pilot, currentUpgrade: Squad.Pilot.Upgrade?, upgradeType: Card.UpgradeType, upgradeButton: UpgradeButton) {
		self.squad = squad
		self.pilot = pilot
		self.currentUpgrade = currentUpgrade
		self.upgradeType = upgradeType
		
		self.transitionPoint = upgradeButton.superview!.convert(upgradeButton.center, to: nil)
		
		super.init(numberOfColumns: 3)
		
		pullToDismissController = PullToDismissController(viewController: self)
		
		transitioningDelegate = self
		modalPresentationStyle = .overCurrentContext
		
		var upgrades: [Card] = []
		var restrictedUpgrades: [Card] = []
		for card in CardStore.cards {
			guard card.type == .upgrade,
				card.upgradeTypes.contains(upgradeType) else {
					continue
			}
			
			if card.validity(in: squad, for: pilot, replacing: currentUpgrade) == .restrictionsNotMet {
				restrictedUpgrades.append(card)
			} else {
				upgrades.append(card)
			}
		}
		
		let upgradeSort: (Card, Card) -> Bool = {
			if $0.pointCost == $1.pointCost {
				return $0.name < $1.name
			}
			return $0.pointCost > $1.pointCost
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
				cards: upgrades.sorted(by: upgradeSort)
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
				cards: restrictedUpgrades.sorted(by: upgradeSort)
			)
		)
	}
	
	required init?(coder aDecoder: NSCoder) {
		fatalError()
	}

	override func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
		pullToDismissController?.scrollViewWillBeginDragging(scrollView)
	}
	
	override func scrollViewDidScroll(_ scrollView: UIScrollView) {
		pullToDismissController?.scrollViewDidScroll(scrollView)
	}
	
	override func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
		pullToDismissController?.scrollViewWillEndDragging(scrollView, withVelocity: velocity, targetContentOffset: targetContentOffset)
	}
	
	override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
		let cardCell = collectionView.dequeueReusableCell(withReuseIdentifier: CardCollectionViewCell.identifier, for: indexPath) as! CardCollectionViewCell

		let card = cardSections[indexPath.section].cards[indexPath.row]
		cardCell.card = card
		cardCell.status = status(for: card)
		cardCell.cardView.delegate = self

		if card == currentUpgrade?.card {
			cardCell.cardView.id = currentUpgrade?.uuid.uuidString
		}

		return cardCell
	}
	
	override func cardViewController(for card: Card) -> CardViewController {
		return CardViewController(card: card, id: id(for: card), pilot: pilot)
	}
	
	override func id(for card: Card) -> String {
		if let currentUpgrade = currentUpgrade, card == currentUpgrade.card {
			return currentUpgrade.uuid.uuidString
		}
		return super.id(for: card)
	}
	
	open override func squadActionForCardViewController(_ cardViewController: CardViewController) -> SquadButton.Action? {
		if cardViewController.card == currentUpgrade?.card {
			return .remove
		}
		
		if cardViewController.card.validity(in: squad, for: pilot, replacing: currentUpgrade) == .valid {
			return .add
		}
		
		return nil
	}
	
	open override func cardViewControllerDidPressSquadButton(_ cardViewController: CardViewController) {
		if let currentUpgrade = currentUpgrade {
			pilot.remove(upgrade: currentUpgrade)
		}
		
		if cardViewController.card != currentUpgrade?.card {
			let upgrade = pilot.addUpgrade(for: cardViewController.card)
			
			cardViewController.cardView.id = upgrade.uuid.uuidString
		}
		
		let window = UIApplication.shared.keyWindow!
		let snapshot = cardViewController.view.snapshotView(afterScreenUpdates: false)!
		window.addSubview(snapshot)
		
		let baseViewController = self.presentingViewController!
		
		baseViewController.dismiss(animated: false) {
			baseViewController.present(cardViewController, animated: false) {
				snapshot.removeFromSuperview()
				baseViewController.dismiss(animated: true, completion: nil)
			}
		}
	}
	
	override func status(for card: Card) -> CardCollectionViewCell.Status {
		guard card.validity(in: squad, for: pilot, replacing: currentUpgrade) == .valid else {
			return .unavailable
		}

		if let currentUpgrade = currentUpgrade,
			card == currentUpgrade.card {
			return .selected
		}

		return .default
	}
	
	override func cardViewDidForcePress(_ cardView: CardView, touches: Set<UITouch>, with event: UIEvent?) {
		guard let card = cardView.card, card.validity(in: squad, for: pilot, replacing: currentUpgrade) == .valid else {
			return
		}
		
		cardView.touchesCancelled(touches, with: event)
		
		if card != currentUpgrade?.card {
			if let currentUpgrade = currentUpgrade {
				pilot.remove(upgrade: currentUpgrade)
			}
			
			let upgrade = pilot.addUpgrade(for: card)
			cardView.id = upgrade.uuid.uuidString
		}
		
		UIImpactFeedbackGenerator(style: .heavy).impactOccurred()
		
		dismiss(animated: true, completion: nil)
	}
}

extension Card {
	
	enum PilotValidity {
		case valid
		case alreadyEquipped
		case slotsNotAvailable
		case uniqueInUse
		case restrictionsNotMet
	}
	
	func validity(in squad: Squad, for pilot: Squad.Pilot, replacing currentUpgrade: Squad.Pilot.Upgrade?) -> PilotValidity {
		// Ensure the any restrictions of the upgrade are met
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
						let action = pilot.card.availableActions.first(where: { $0.baseType.rawValue == actionID }) {
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
						pilot.card.shipType?.rawValue == shipID {
						passedSet = true
					}
					
				case .shipSize:
					if let shipSize = restriction.parameters.shipSizeName {
						switch shipSize {
						case .small:
							if pilot.card.shipSize == .small {
								passedSet = true
							}
						case .medium:
							if pilot.card.shipSize == .medium {
								passedSet = true
							}
						case .large:
							if pilot.card.shipSize == .large {
								passedSet = true
							}
						}
					}
					
				case .cardIncluded:
					if let cardID = restriction.parameters.id {
						for pilot in squad.pilots {
							if pilot.card.id == cardID ||
								pilot.upgrades.contains(where: { $0.card.id == cardID }) {
								passedSet = true
								break
							}
						}
					}
					
				case .arc:
					if let arcID = restriction.parameters.id,
						pilot.card.statistics.contains(where: { $0.type.rawValue == arcID }) {
						passedSet = true
					}
					
				case .forceSide:
					if let forceSide = restriction.parameters.forceSideName {
						switch forceSide {
						case .light:
							if pilot.card.forceSide == .light {
								passedSet = true
							}
						case .dark:
							if pilot.card.forceSide == .dark {
								passedSet = true
							}
						}
					}
				}
				
				if passedSet { break }
			}
			
			guard passedSet else { return .restrictionsNotMet }
		}
		
		// Ensure the the pilot has the correct upgrade slots available for the upgrade
		var availableUpgradeSlots = pilot.upgrades.reduce(pilot.card.availableUpgrades) { availableUpgrades, upgrade in
			if upgrade.uuid == currentUpgrade?.uuid {
				return availableUpgrades
			}
			
			var availableUpgrades = availableUpgrades
			for upgradeType in upgrade.card.upgradeTypes {
				if let index = availableUpgrades.index(of: upgradeType) {
					availableUpgrades.remove(at: index)
				}
			}
			return availableUpgrades
		}
		
		for upgradeType in upgradeTypes {
			guard let index = availableUpgradeSlots.index(of: upgradeType) else {
				return .slotsNotAvailable
			}
			availableUpgradeSlots.remove(at: index)
		}
		
		// Unique cards can only be in a squad once
		if isUnique {
			for pilot in squad.pilots {
				if pilot.card.name == name {
					return .uniqueInUse
				}
				if let uniqueUpgrade = pilot.upgrades.first(where: { $0.card.name == name }), uniqueUpgrade.uuid != currentUpgrade?.uuid {
					return .uniqueInUse
				}
			}
		}
		
		// A pilot can never have two of the same upgrade
		for upgrade in pilot.upgrades {
			if upgrade.card == self, upgrade.uuid != currentUpgrade?.uuid {
				return .alreadyEquipped
			}
		}
		
		return .valid
	}
	
}

extension SelectUpgradeViewController: UIViewControllerTransitioningDelegate {
	
	func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
		return CardsPresentAnimationController()
	}
	
	func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
		return CardsDismissAnimationController()
	}
	
	func interactionControllerForDismissal(using animator: UIViewControllerAnimatedTransitioning) -> UIViewControllerInteractiveTransitioning? {
		return nil
	}
}
