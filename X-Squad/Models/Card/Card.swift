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
	var image: URL { get }
	var orientation: CardOrientation { get }
}

enum CardOrientation {
	case portrait
	case landscape
}

extension Card {
	func pointCost(for member: Squad.Member?) -> Int {
		switch self {
		case let pilot as Pilot:
			return pilot.cost
		case let upgrade as Upgrade:
			switch upgrade.cost {
			case .constant(let cost):
				return cost
			case .variable(let variable):
				#warning("Unimplemented")
				return 0
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
	var image: URL {
		return sides.first!.image
	}
	
	var orientation: CardOrientation { return .landscape }
}
