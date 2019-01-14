//
//  Squad.swift
//  X-Squad
//
//  Created by Avario on 10/01/2019.
//  Copyright © 2019 Avario. All rights reserved.
//

import Foundation

class Squad: Codable {
	let uuid: UUID
	
	let faction: Card.Faction
	var pilots: WritableDynamic<[Pilot]>
	
	init(faction: Card.Faction) {
		self.uuid = UUID()
		self.faction = faction
		self.pilots = WritableDynamic([])
	}
	
	var cost: Int {
		return 157
	}
	
	class Pilot: Codable {
		let uuid: UUID
		let cardID: Int
		
		var upgrades: WritableDynamic<[Upgrade]>
		
		var card: Card? {
			return CardStore.card(forID: cardID)
		}
		
		init(card: Card) {
			self.uuid = UUID()
			self.cardID = card.id
			self.upgrades = WritableDynamic([])
		}
		
		class Upgrade: Codable {
			let uuid: UUID
			let cardID: Int
			
			var card: Card? {
				return CardStore.card(forID: cardID)
			}
			
			init(card: Card) {
				self.uuid = UUID()
				self.cardID = card.id
			}
		}
	}
	
}

extension Squad: Hashable {
	static func == (lhs: Squad, rhs: Squad) -> Bool {
		return lhs.uuid == rhs.uuid
	}
	
	public func hash(into hasher: inout Hasher) {
		uuid.hash(into: &hasher)
	}
}
