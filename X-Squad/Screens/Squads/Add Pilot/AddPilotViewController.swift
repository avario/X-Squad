//
//  AddPilotViewController.swift
//  X-Squad
//
//  Created by Avario on 11/01/2019.
//  Copyright © 2019 Avario. All rights reserved.
//
// This Screen allows user's to add a pilot to squad by presenting a collection of all pilot cards.

import Foundation
import UIKit

class AddPilotViewController: CardsCollectionViewController {
	
	let squad: Squad
	
	var pullToDismissController: PullToDismissController?
	
	init(squad: Squad) {
		self.squad = squad
		
		let columnLayout: CardCollectionViewLayout.ColumnLayout
		switch UIDevice.current.userInterfaceIdiom {
		case .pad:
			columnLayout = .width(200)
		case .phone:
			columnLayout = .number(4)
		default:
			fatalError()
		}
		
		super.init(columnLayout: columnLayout)
		
		pullToDismissController = PullToDismissController()
		pullToDismissController?.viewController = self
		
		transitioningDelegate = self
		modalPresentationStyle = .overCurrentContext
		
		// The ships are sorted by how many pilots they have, then by name.
		let ships = DataStore.shared.ships.filter({ $0.faction == squad.faction }).sorted {
			let pilotCount0: Int
			let pilotCount1: Int
			
			if squad.isHyperspaceOnly {
				pilotCount0 = $0.pilots.filter({ $0.hyperspace == true }).count
				pilotCount1 = $1.pilots.filter({ $0.hyperspace == true }).count
			} else {
				pilotCount0 = $0.pilots.count
				pilotCount1 = $1.pilots.count
			}
			
			if pilotCount0 == pilotCount1 {
				return $0.name < $1.name
			} else {
				return pilotCount0 > pilotCount1
			}
		}
		
		// Pilots are sorted into sections by their ship.
		for ship in ships {
			// Within a ship section, pilots are sorted according to PS and cost.
			let sortedPilots = ship.pilots.sorted(by: Squad.rankPilots)
			
			cardSections.append(
				CardSection(
					header: .header(
						CardSection.HeaderInfo(
							title: "",//shipType.title,
							icon: ship.characterCode,
							iconFont: UIFont.xWingShip(48)
						)
					),
					cards: sortedPilots
				)
			)
		}
	}
	
	required init?(coder aDecoder: NSCoder) {
		fatalError()
	}

	// The pull to dismiss methods must be forwarded because this view must be the delegate (because it's a collection view).
	override func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
		pullToDismissController?.scrollViewWillBeginDragging(scrollView)
	}
	
	override func scrollViewDidScroll(_ scrollView: UIScrollView) {
		pullToDismissController?.scrollViewDidScroll(scrollView)
	}
	
	override func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
		pullToDismissController?.scrollViewWillEndDragging(scrollView, withVelocity: velocity, targetContentOffset: targetContentOffset)
	}
	
	override func squadAction(for card: Card) -> SquadButton.Action? {
		return status(for: card) == .default ? .add("Add to Squad") : nil
	}
	
	override func cardDetailsCollectionViewController(_ cardDetailsCollectionViewController: CardDetailsCollectionViewController, didPressSquadButtonFor card: Card) {
		let pilot = card as! Pilot
		let member = squad.addMember(for: pilot)
		
		cardDetailsCollectionViewController.currentCell?.member = member
		
		// The squad view controller is set as the target and this screen is set to hidden so it looks like the presented card screen transitions directly to the squad screen.
		self.view.isHidden = true
		cardDetailsCollectionViewController.dismissTargetViewController = self.presentingViewController
		cardDetailsCollectionViewController.dismiss(animated: true) {
			self.dismiss(animated: false, completion: nil)
		}
	}
	
	override func status(for card: Card) -> CardCollectionViewCell.Status {
		// Show cards the have reached their limit in the squad as dimmed.
		switch squad.limitStatus(for: card) {
		case .available:
			if squad.isHyperspaceOnly {
				guard card.hyperspace == true else {
					return .unavailable
				}
			}
			return .default
		case .exceeded, .met:
			return .unavailable
		}
	}

}

extension AddPilotViewController: UIViewControllerTransitioningDelegate {
	
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

