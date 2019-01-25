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
	var image: URL? { get }
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
				}
			}
		default:
			fatalError()
		}
	}
}

extension Pilot: Card {
	var orientation: CardOrientation { return .portrait }
}

extension Upgrade: Card {
	var image: URL? {
		return sides.first!.image
	}
	
	var orientation: CardOrientation { return .landscape }
}
