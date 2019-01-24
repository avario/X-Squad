//
//  Pilot.swift
//  X-Squad
//
//  Created by Avario on 22/01/2019.
//  Copyright © 2019 Avario. All rights reserved.
//

import Foundation

class Pilot: Codable {
	
	let name: String
	let caption: String?
	let initiative: Int
	let limited: Int
	let cost: Int?
	let xws: XWS
	let ffg: Int?
	let hyperspace: Bool
	let ability: String?
	let shipAbility: ShipAbility?
	let text: String?
	let image: URL?
	let artwork: URL?
	let force: Force?
	let charges: Charges?
	let slots: [Upgrade.UpgradeType]?
	
	struct ShipAbility: Codable {
		let name: String
		let text: String
	}
}

extension Pilot: Hashable {
	static func == (lhs: Pilot, rhs: Pilot) -> Bool {
		return lhs.xws == rhs.xws
	}
	
	public func hash(into hasher: inout Hasher) {
		xws.hash(into: &hasher)
	}
}
