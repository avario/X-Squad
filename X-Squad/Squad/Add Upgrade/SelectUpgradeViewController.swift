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
	
	private var animator = UIDynamicAnimator(referenceView: UIApplication.shared.keyWindow!)
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
		cardCell.status = status(for: card, at: indexPath)

		if card.id == currentUpgrade?.cardID {
			cardCell.cardView.id = currentUpgrade?.uuid.uuidString
		}

		return cardCell
	}
	
	override func id(for card: Card) -> String {
		if let currentUpgrade = currentUpgrade, card.id == currentUpgrade.cardID {
			return currentUpgrade.uuid.uuidString
		}
		return super.id(for: card)
	}
	
	override func cardViewController(_ cardViewController: CardViewController, didSelect card: Card) {
		let upgrade = Squad.Pilot.Upgrade(card: card)
		pilot.upgrades.value.append(upgrade)
		SquadStore.save()
		presentingViewController?.dismiss(animated: true, completion: nil)
	}
	
	override func status(for card: Card, at index: IndexPath) -> CardCollectionViewCell.Status {
		if index.section > 0 {
			return .unavailable
		}

		if let currentUpgrade = currentUpgrade,
			card.id == currentUpgrade.cardID {
			return .selected
		}

		if card.isUnique {
			for pilot in squad.pilots.value {
				if pilot.card?.name == card.name || pilot.upgrades.value.contains(where: { $0.card?.name == card.name }) {
					return .unavailable
				}
			}
		}

		return .default
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
