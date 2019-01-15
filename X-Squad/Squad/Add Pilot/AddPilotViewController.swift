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
	
	init(squad: Squad) {
		self.squad = squad
		super.init(numberOfColumns: 4)
		
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
			let sortedPilots = pilots.sorted {
				guard let initiative0 = $0.initiative else {
					return false
				}
				
				guard let initiative1 = $1.initiative else {
					return true
				}
				
				if initiative0 == initiative1 {
					if $0.pointCost == $1.pointCost {
						return $0.name < $1.name
					}
					return $0.pointCost > $1.pointCost
				}
				return initiative0 > initiative1
			}
			
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
		squad.pilots.value.append(Squad.Pilot(card: card))
		SquadStore.save()
		presentingViewController?.dismiss(animated: true, completion: nil)
	}
	
	override func status(for card: Card, at index: IndexPath) -> CardCollectionViewCell.Status {
		return card.isUnique && squad.pilots.value.contains(where: { $0.card?.name == card.name }) ? .unavailable : .default
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
