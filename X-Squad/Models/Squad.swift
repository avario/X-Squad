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
	
	var pointCost: Int {
		return pilots.reduce(0, { $0 + $1.pointCost })
	}
	
	@discardableResult func addPilot(for card: Card) -> Pilot {
		let pilot = Pilot(card: card)
		pilots.append(pilot)
		pilots.sort(by: { Squad.rankPilots($0.card, $1.card) })
		
		SquadStore.save()
		NotificationCenter.default.post(name: .squadStoreDidAddPilotToSquad, object: self)
		NotificationCenter.default.post(name: .squadStoreDidUpdateSquad, object: self)
		
		return pilot
	}
	
	func remove(pilot: Pilot) {
		if let index = pilots.firstIndex(where: { $0.uuid == pilot.uuid }) {
			pilots.remove(at: index)
		}
		
		for pilot in pilots {
			pilot.removeInValidUpgrades(shouldNotify: true)
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
		
		var pointCost: Int {
			return upgrades.reduce(card.pointCost, { $0 + $1.card.pointCost(for: self) })
		}
		
		var allUpgradeSlots: [Card.UpgradeType] {
			var availableUpgrades = upgrades.reduce(card.availableUpgrades.filter({ $0 != .special }), { availableUpgrades, upgrade in
				var upgrades = availableUpgrades + upgrade.card.addedUpgradeSlots
				
				for removedUpgrade in upgrade.card.removedUpgradeSlots {
					if let index = upgrades.firstIndex(of: removedUpgrade) {
						upgrades.remove(at: index)
					}
				}
				
				return upgrades
			})
			
			if card.abilityText.contains("Weapon Hardpoint") {
				let hardpointUpgrades: [Card.UpgradeType] = [.cannon, .torpedo, .missile]
				if let equippedHardpointUpgrade = upgrades.first(where: { $0.card.upgradeTypes.contains(where: { hardpointUpgrades.contains($0) })}) {
					availableUpgrades.append(equippedHardpointUpgrade.card.upgradeTypes.first!)
				} else {
					availableUpgrades.append(contentsOf: hardpointUpgrades)
				}
			}
			
			return availableUpgrades
		}
		
		var allActions: [Card.Action] {
			return upgrades.reduce(card.availableActions, { $0 + $1.card.availableActions })
		}
		
		@discardableResult func addUpgrade(for upgradeCard: Card) -> Upgrade {
			let upgrade = Upgrade(card: upgradeCard)
			upgrades.append(upgrade)
			
			removeInValidUpgrades()
			
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
			
			return upgrade
		}
		
		func remove(upgrade: Upgrade) {
			if let index = upgrades.firstIndex(where: { $0.uuid == upgrade.uuid }) {
				upgrades.remove(at: index)
			}
			
			removeInValidUpgrades()
			
			SquadStore.save()
			NotificationCenter.default.post(name: .squadStoreDidRemoveUpgradeFromPilot, object: self)
			NotificationCenter.default.post(name: .squadStoreDidUpdateSquad, object: squad)
		}
		
		func removeInValidUpgrades(shouldNotify: Bool = false, notify: Bool = false) {
			removeUpgradesThatNoLongerHaveSlots()
			
			guard let squad = squad else { return }
			
			var invalidUpgrade: Upgrade? = nil
			
			for upgrade in upgrades {
				guard upgrade.card.validity(in: squad, for: self, replacing: upgrade) == .valid else {
					invalidUpgrade = upgrade
					break
				}
			}
			
			if let invalidUpgrade = invalidUpgrade,
				let index = upgrades.firstIndex(where: { $0.uuid == invalidUpgrade.uuid }) {
				upgrades.remove(at: index)
				removeInValidUpgrades(shouldNotify: shouldNotify, notify: true)
			}
			
			if shouldNotify, notify {
				NotificationCenter.default.post(name: .squadStoreDidRemoveUpgradeFromPilot, object: self)
				NotificationCenter.default.post(name: .squadStoreDidUpdateSquad, object: squad)
			}
		}
		
		private func removeUpgradesThatNoLongerHaveSlots() {
			var availableUpgradeSlots = allUpgradeSlots
			var upgradesToRemove: [Upgrade] = []
			
			for upgrade in upgrades {
				for upgradeType in upgrade.card.upgradeTypes {
					guard availableUpgradeSlots.contains(upgradeType) else {
						upgradesToRemove.append(upgrade)
						break
					}
					availableUpgradeSlots.remove(at: availableUpgradeSlots.firstIndex(of: upgradeType)!)
				}
			}
			
			for upgrade in upgradesToRemove {
				guard let index = upgrades.firstIndex(where: { $0.uuid == upgrade.uuid }) else {
					continue
				}
				upgrades.remove(at: index)
			}
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
