//
//  SelectUpgradeViewController.swift
//  X-Squad
//
//  Created by Avario on 13/01/2019.
//  Copyright © 2019 Avario. All rights reserved.
//
// This screen allows user's to select an upgrade to add to a pilot.

import Foundation
import UIKit

class SelectUpgradeViewController: CardsCollectionViewController {
	
	let squad: Squad
	let member: Squad.Member
	let currentUpgrade: Upgrade?
	let upgradeType: Upgrade.UpgradeType
	
	var pullToDismissController: PullToDismissController?
	
	init(squad: Squad, member: Squad.Member, currentUpgrade: Upgrade?, upgradeType: Upgrade.UpgradeType) {
		self.squad = squad
		self.member = member
		self.currentUpgrade = currentUpgrade
		self.upgradeType = upgradeType
		
		let columnLayout: CardCollectionViewLayout.ColumnLayout
		switch UIDevice.current.userInterfaceIdiom {
		case .pad:
			columnLayout = .width(300)
		case .phone:
			columnLayout = .number(3)
		default:
			fatalError()
		}
		
		super.init(columnLayout: columnLayout)
		
		pullToDismissController = PullToDismissController()
		pullToDismissController?.viewController = self
		
		transitioningDelegate = self
		modalPresentationStyle = .overCurrentContext
		
		var upgrades: [Upgrade] = []
		var restrictedUpgrades: [Upgrade] = []
		
		for upgrade in DataStore.shared.upgrades {
			guard upgrade.frontSide.slots.contains(upgradeType) else {
					continue
			}
			
			let validity = self.validity(of: upgrade)
			
			if validity == .restrictionsNotMet || validity == .notHyperspace {
				restrictedUpgrades.append(upgrade)
			} else {
				upgrades.append(upgrade)
			}
		}
		
		// Sort upgrades by point cost, then by name.
		let upgradeSort: (Upgrade, Upgrade) -> Bool = {
			if $0.pointCost(for: member) == $1.pointCost(for: member) {
				return $0.name < $1.name
			}
			return $0.pointCost(for: member) > $1.pointCost(for: member)
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
		
		// Restricted upgrades will be shown in a section at the bottom of the list.
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

		let upgrade = cardSections[indexPath.section].cards[indexPath.row] as! Upgrade
		cardCell.card = upgrade
		cardCell.status = status(for: upgrade)
		cardCell.cardView.delegate = self
		
		if upgrade == currentUpgrade {
			cardCell.cardView.member = member
		} else {
			cardCell.cardView.member = nil
		}

		return cardCell
	}
	
	override func squadAction(for card: Card) -> SquadButton.Action? {
		if card as? Upgrade == currentUpgrade {
			return .remove("Remove from Pilot")
		}
		
		if validity(of: card as! Upgrade) == .valid {
			return .add("Add to Pilot")
		}
		
		return nil
	}
	
	override func cardDetailsCollectionViewController(_ cardDetailsCollectionViewController: CardDetailsCollectionViewController, didPressSquadButtonFor card: Card) {
		if let currentUpgrade = currentUpgrade {
			member.removeUpgrade(currentUpgrade)
		}
		
		if card as? Upgrade != currentUpgrade {
			member.addUpgrade(card as! Upgrade)
			cardDetailsCollectionViewController.currentCell?.member = member
		}
		
		// The squad view controller is set as the target and this screen is set to hidden so it looks like the presented card screen transitions directly to the squad screen.
		self.view.isHidden = true
		cardDetailsCollectionViewController.dismissTargetViewController = self.presentingViewController
		cardDetailsCollectionViewController.dismiss(animated: true) {
			self.dismiss(animated: false, completion: nil)
		}
	}
	
	override func cost(for card: Card) -> Int {
		return card.pointCost(for: member)
	}
	
	override func status(for card: Card) -> CardCollectionViewCell.Status {
		let upgrade = card as! Upgrade
		
		guard validity(of: upgrade) == .valid else {
			return .unavailable
		}

		if let currentUpgrade = currentUpgrade,
			upgrade == currentUpgrade {
			return .selected
		}

		return .default
	}
	
	override func cardViewDidForcePress(_ cardView: CardView, touches: Set<UITouch>, with event: UIEvent?) {
		guard let upgrade = cardView.card as? Upgrade, validity(of: upgrade) == .valid else {
			return
		}
		
		cardView.touchesCancelled(touches, with: event)
		
		if upgrade != currentUpgrade {
			if let currentUpgrade = currentUpgrade {
				member.removeUpgrade(currentUpgrade)
			}
			
			member.addUpgrade(upgrade)
			cardView.member = member
		}
		
		UIImpactFeedbackGenerator(style: .heavy).impactOccurred()
		
		dismiss(animated: true, completion: nil)
	}
	
	func validity(of upgrade: Upgrade) -> Squad.Member.UpgradeValidity {
		return member.validity(of: upgrade, replacing: currentUpgrade)
	}
	
	override func member(for card: Card) -> Squad.Member? {
		if let currentUpgrade = currentUpgrade, card.matches(currentUpgrade) {
			return member
		}
		return nil
	}
	
}

extension SelectUpgradeViewController: UIViewControllerTransitioningDelegate {
	
	func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
		return CardsPresentAnimationController(style: .smooth)
	}
	
	func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
		return CardsDismissAnimationController(targetViewController: nil, style: .smooth)
	}
	
	func interactionControllerForDismissal(using animator: UIViewControllerAnimatedTransitioning) -> UIViewControllerInteractiveTransitioning? {
		return nil
	}
}
