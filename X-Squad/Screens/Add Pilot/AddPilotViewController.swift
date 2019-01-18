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
		
		var pilots: [Card.ShipType: [Card]] = [:]
		
		for card in CardStore.cards {
			if card.type == .pilot,
				card.faction == squad.faction,
				let shipType = card.shipType {
				
				if pilots[shipType] != nil {
					pilots[shipType]!.append(card)
				} else {
					pilots[shipType] = [card]
				}
			}
		}
		
		for (shipType, pilots) in pilots {
			
			// Sort the pilots by pilot skill, then by cost, then by name
			let sortedPilots = pilots.sorted(by: Squad.rankPilots)
			
			cardSections.append(
				CardSection(
					header: .header(
						CardSection.HeaderInfo(
							title: "",//shipType.title,
							icon: shipType.characterCode,
							iconFont: UIFont.xWingShip(48)
						)
					),
					cards: sortedPilots
				)
			)
		}
		
		// Sort the ship sections by the number of cards in them, then alphabetically
		cardSections = cardSections.sorted {
			if $0.cards.count == $1.cards.count {
				return $0.cards.first!.shipType!.title < $1.cards.first!.shipType!.title
			} else {
				return $0.cards.count > $1.cards.count
			}
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
		let pilot = squad.addPilot(for: cardViewController.card)
		
		cardViewController.cardView.id = pilot.uuid.uuidString
		
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
		return card.isUnique && squad.pilots.contains(where: {
			$0.card.name == card.name ||
				$0.upgrades.contains(where: {
					$0.card.name == card.name }) }) ? .unavailable : .default
	}
	
}

extension AddPilotViewController: UIGestureRecognizerDelegate {
	
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

extension Card.ShipType {
	var title: String {
		switch self {
		case .modifiedYT1300:
			return "Modified YT1300"
		case .starViper:
			return "Star Viper"
		case .scurrgH6Bomber:
			return "Scurgg H6 Bomber"
		case .YT2400:
			return "YT2400"
		case .auzituckGunship:
			return "Auzituck Gunship"
		case .kihraxzFighter:
			return "Kihraxz Fighter"
		case .sheathipede:
			return "Sheathipede"
		case .quadrijetSpacetug:
			return "Duadrijet"
		case .firespray:
			return "Firespray"
		case .TIElnFighter:
			return "TIE/ln Fighter"
		case .BTLA4Ywing:
			return "BTLA4 Y-wing"
		case .TIEAdvancedx1:
			return "TIE Advanced x1"
		case .alphaclassStarWing:
			return "Alpha-class Star Wing"
		case .UT60DUwing:
			return "UT60 U-wing"
		case .TIEskStriker:
			return "TIE/sk Striker"
		case .ASF01Bwing:
			return "ASF01 B-wing"
		case .TIEDDefender:
			return "TIE/d Defender"
		case .TIEsaBomber:
			return "TIE/sa Bomber"
		case .TIEcsPunisher:
			return "TIE/cs Punisher"
		case .aggressor:
			return "Aggressor"
		case .G1AStarfighter:
			return "G1A Starfighter"
		case .VCX100:
			return "VCX100"
		case .YV666:
			return "YV666"
		case .TIEAdvancedv1:
			return "TIE Advanced v1"
		case .lambdaShuttle:
			return "Lambda Shuttle"
		case .TIEphPhantom:
			return "TIE/ph Phantom"
		case .VT49Decimator:
			return "VT49 Decimator"
		case .TIEagAggressor:
			return "TIE/ag Aggressor"
		case .BTLS8Kwing:
			return "BTLS8 K-wing"
		case .ARC170Starfighter:
			return "ARC170 Starfighter"
		case .attackShuttle:
			return "Attack Shuttle"
		case .T65Xwing:
			return "T-65 X-wing"
		case .HWK290:
			return "HWK290"
		case .RZ1Awing:
			return "RZ1 A-wing"
		case .fangFighter:
			return "Fang Fighter"
		case .Z95AF4Headhunter:
			return "Z95AF4 Headhunter"
		case .M12LKimogila:
			return "M12L Kimogila"
		case .Ewing:
			return "E-wing"
		case .TIEInterceptor:
			return "TIE Interceptor"
		case .lancerPursuitCraft:
			return "Lancer Pursuit Craft"
		case .TIEReaper:
			return "TIE Reaper"
		case .M3AInterceptor:
			return "M3A Interceptor"
		case .jumpMaster5000:
			return "JumpMaster 5000"
		case .customizedYT1300:
			return "Customized YT1300"
		case .escapeCraft:
			return "Escape Craft"
		case .TIEfoFighter:
			return "TIE/fo Fighter"
		case .TIEsfFighter:
			return "TIE/sf Fighter"
		case .upsilonclassCommandShuttle:
			return "Upsilon-class Command Shuttle"
		case .TIEvnSilencer:
			return "TIE/vn Silencer"
		case .T70Xwing:
			return "T-70 X-wing"
		case .RZ2Awing:
			return "RZ2 A-wing"
		case .MG100StarFortress:
			return "MG100 Star Fortress"
		case .modifiedTIEln:
			return "Modified TIE/ln"
		case .scavengedYT1300:
			return "Scavenged YT1300"
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

