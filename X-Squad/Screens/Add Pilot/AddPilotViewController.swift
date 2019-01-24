//
//  AddPilotViewController.swift
//  X-Squad
//
//  Created by Avario on 11/01/2019.
//  Copyright © 2019 Avario. All rights reserved.
//

import Foundation
import UIKit

class AddPilotViewController: CardsViewController {
	
	let squad: Squad
	
	var pullToDismissController: PullToDismissController?
	
	init(squad: Squad) {
		self.squad = squad
		super.init(numberOfColumns: 4)
		
		pullToDismissController = PullToDismissController(viewController: self)
		
		transitioningDelegate = self
		modalPresentationStyle = .overCurrentContext
		
		let ships = DataStore.ships.filter({ $0.faction == squad.faction }).sorted {
			if $0.pilots.count == $1.pilots.count {
				return $0.name < $1.name
			} else {
				return $0.pilots.count > $1.pilots.count
			}
		}
		
		for ship in ships {
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

	override func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
		pullToDismissController?.scrollViewWillBeginDragging(scrollView)
	}
	
	override func scrollViewDidScroll(_ scrollView: UIScrollView) {
		pullToDismissController?.scrollViewDidScroll(scrollView)
	}
	
	override func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
		pullToDismissController?.scrollViewWillEndDragging(scrollView, withVelocity: velocity, targetContentOffset: targetContentOffset)
	}
	
	open override func squadActionForCardViewController(_ cardViewController: CardViewController) -> SquadButton.Action? {
		return status(for: cardViewController.card) == .default ? .add : nil
	}
	
	open override func cardViewControllerDidPressSquadButton(_ cardViewController: CardViewController) {
		let pilot = cardViewController.card as! Pilot
		let member = squad.addMember(for: pilot)
		
		cardViewController.cardView.member = member
		
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
		switch squad.limitStatus(for: card) {
		case .available:
			return .default
		case .exceeded, .met:
			return .unavailable
		}
	}
	
	override func cardViewDidForcePress(_ cardView: CardView, touches: Set<UITouch>, with event: UIEvent?) {
		let pilot = cardView.card as! Pilot
		guard squad.limitStatus(for: pilot) == .available else {
			return
		}
		
		cardView.touchesCancelled(touches, with: event)
		
		let member = squad.addMember(for: pilot)
		cardView.member = member
		
		UIImpactFeedbackGenerator(style: .heavy).impactOccurred()
		
		dismiss(animated: true, completion: nil)
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

