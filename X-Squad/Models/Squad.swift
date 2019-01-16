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
	private(set) var pilots: [Pilot]
	
	init(faction: Card.Faction) {
		self.uuid = UUID()
		self.faction = faction
		self.pilots = []
	}
	
	var cost: Int {
		var total = 0
		for pilot in pilots {
			total += pilot.card.pointCost
			for upgrade in pilot.upgrades {
				total += upgrade.card.pointCost(for: pilot)
			}
		}
		return total
	}
	
	func addPilot(for card: Card) {
		pilots.append(Pilot(card: card))
		pilots.sort(by: { Squad.rankPilots($0.card, $1.card) })
		
		SquadStore.save()
		NotificationCenter.default.post(name: .squadStoreDidAddPilotToSquad, object: self)
		NotificationCenter.default.post(name: .squadStoreDidUpdateSquad, object: self)
	}
	
	func remove(pilot: Pilot) {
		if let index = pilots.firstIndex(where: { $0.uuid == pilot.uuid }) {
			pilots.remove(at: index)
		}
		
		SquadStore.save()
		NotificationCenter.default.post(name: .squadStoreDidRemovePilotFromSquad, object: self)
		NotificationCenter.default.post(name: .squadStoreDidUpdateSquad, object: self)
	}
	
	static let rankPilots: (Card, Card) -> Bool = {
		guard let initiative0 = $0.initiative else {
			return false
		}
		
		guard let initiative1 = $1.initiative else {
			return true
		}
		
		if initiative0 == initiative1 {
			if $0.pointCost == $1.pointCost {
				return $0.name > $1.name
			}
			return $0.pointCost > $1.pointCost
		}
		return initiative0 > initiative1
	}
	
	class Pilot: Codable {
		let uuid: UUID
		let card: Card
		private(set) var upgrades: [Upgrade]
		
		init(card: Card) {
			self.uuid = UUID()
			self.card = card
			self.upgrades = []
		}
		
		var squad: Squad? {
			return SquadStore.squads.first(where: { $0.pilots.contains(where: { $0.uuid == uuid }) })
		}
		
		func addUpgrade(for card: Card) {
			upgrades.append(Upgrade(card: card))
			upgrades.sort { (lhs, rhs) -> Bool in
				guard let lhsType = lhs.card.upgradeTypes.first,
					let lhsIndex = card.availableUpgrades.firstIndex(of: lhsType),
					let rhsType = rhs.card.upgradeTypes.first,
					let rhsIndex = card.availableUpgrades.firstIndex(of: rhsType) else {
						return false
				}
				
				if lhsType == rhsType {
					return lhs.card.name < rhs.card.name
				} else {
					return lhsIndex < rhsIndex
				}
			}
			
			SquadStore.save()
			NotificationCenter.default.post(name: .squadStoreDidAddUpgradeToPilot, object: self)
			NotificationCenter.default.post(name: .squadStoreDidUpdateSquad, object: squad)
		}
		
		func remove(upgrade: Upgrade) {
			if let index = upgrades.firstIndex(where: { $0.uuid == upgrade.uuid }) {
				upgrades.remove(at: index)
			}
			
			SquadStore.save()
			NotificationCenter.default.post(name: .squadStoreDidRemoveUpgradeFromPilot, object: self)
			NotificationCenter.default.post(name: .squadStoreDidUpdateSquad, object: squad)
		}
		
		class Upgrade: Codable {
			let uuid: UUID
			let card: Card
			
			init(card: Card) {
				self.uuid = UUID()
				self.card = card
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
