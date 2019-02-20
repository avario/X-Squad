//
//  Card.swift
//  X-Squad
//
//  Created by Avario on 22/01/2019.
//  Copyright © 2019 Avario. All rights reserved.
//

import Foundation

protocol Card {
	var name: String { get }
	var limited: Int { get }
	var frontImage: URL? { get }
	var backImage: URL? { get }
	var hyperspace: Bool? { get }
	var orientation: CardOrientation { get }
}

enum CardOrientation {
	case portrait
	case landscape
}

extension Card {
	func pointCost(for member: Squad.Member? = nil) -> Int {
		switch self {
		case let pilot as Pilot:
			return pilot.cost ?? 0
		case let upgrade as Upgrade:
			guard let cost = upgrade.cost else {
				return 0
			}
			
			switch cost {
			case .constant(let cost):
				return cost
			case .variable(let variable):
				guard let member = member else {
					return 0
				}
				
				switch variable {
				case .size(let sizeValues):
					return sizeValues[member.pilot.ship!.size]!
				
				case .agility(let agilityValues):
					let agility = member.pilot.ship!.stats.first(where: { $0.type == .agility })!
					return agilityValues[Upgrade.Cost.Variable.Agility(rawValue: String(agility.value))!]!
					
				case .initiative(let initiativeValues):
					let initiative = member.pilot.initiative
					return initiativeValues[Upgrade.Cost.Variable.Initiative(rawValue: String(initiative))!]!
				}
			}
		default:
			fatalError()
		}
	}
	
	var isReleased: Bool {
		switch self {
		case let pilot as Pilot:
			return pilot.cost != nil
		case let upgrade as Upgrade:
			return upgrade.cost != nil
		default:
			fatalError()
		}
	}
}

extension Pilot: Card {
	var frontImage: URL? {
		return image
	}
	
	var backImage: URL? {
		return nil
	}
	
	var orientation: CardOrientation { return .portrait }
}

extension Upgrade: Card {
	var frontImage: URL? {
		return frontSide.image
	}
	
	var backImage: URL? {
		return backSide?.image
	}
	
	var orientation: CardOrientation { return .landscape }
}
