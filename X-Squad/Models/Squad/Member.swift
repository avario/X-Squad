//
//  Member.swift
//  X-Squad
//
//  Created by Avario on 22/01/2019.
//  Copyright © 2019 Avario. All rights reserved.
//

import Foundation

extension Squad {
	class Member: Codable {
		let uuid: UUID
		
		let shipXWS: XWSID
		let pilotXWS: XWSID
		var upgradesXWS: [XWSID]
		
		lazy var ship: Ship = DataStore.shared.ship(for: shipXWS) ?? DataStore.shared.ships.first!
		lazy var pilot: Pilot = DataStore.shared.pilot(for: pilotXWS) ?? DataStore.shared.ships.first!.pilots.first!
		lazy var upgrades: [Upgrade] = upgradesXWS.map({ DataStore.shared.upgrade(for: $0) ?? DataStore.shared.upgrades.first! }).sorted(by: upgradeSort)
		
		init(ship: Ship, pilot: Pilot, upgrades: [Upgrade] = []) {
			self.uuid = UUID()
			self.shipXWS = ship.xws
			self.pilotXWS = pilot.xws
			self.upgradesXWS = upgrades.map({ $0.xws })
		}
		
		func update(from record: Member) {
			for upgrade in upgrades {
				if record.upgrades.contains(upgrade) == false {
					removeUpgrade(upgrade, syncWithCloud: false)
				}
			}
			
			for upgrade in record.upgrades {
				if upgrades.contains(upgrade) == false {
					addUpgrade(upgrade)
				}
			}
		}
		
		var squad: Squad {
			return SquadStore.shared.squads.first(where: { $0.members.contains(self) })!
		}
		
		var pointCost: Int {
			return upgrades.reduce(pilot.pointCost(), { $0 + $1.pointCost(for: self) })
		}
		
		lazy var upgradeSort: (Upgrade, Upgrade) -> Bool = { (lhs, rhs) -> Bool in
			let upgradeSlots = self.pilot.slots ?? []

			let lhsType = lhs.frontSide.type
			let rhsType = rhs.frontSide.type

			let lhsIndex = upgradeSlots.firstIndex(of: lhsType) ?? 999
			let rhsIndex = upgradeSlots.firstIndex(of: rhsType) ?? 999

			if lhsIndex == rhsIndex {
				return lhs.name < rhs.name
			} else {
				return lhsIndex < rhsIndex
			}
		}
		
		func addUpgrade(_ upgrade: Upgrade, syncWithCloud: Bool = true) {
			upgradesXWS.append(upgrade.xws)
			upgrades.append(upgrade)
			
			removeInvalidUpgrades()
			
			upgrades.sort(by: upgradeSort)
			
			SquadStore.shared.saveSquad(self.squad, syncWithCloud: syncWithCloud)
			
			DispatchQueue.main.async {
				NotificationCenter.default.post(name: .squadStoreDidAddUpgradeToMember, object: self)
				NotificationCenter.default.post(name: .squadStoreDidUpdateSquad, object: self.squad)
			}
		}
		
		func removeUpgrade(_ upgrade: Upgrade, syncWithCloud: Bool = true) {
			if let index = upgrades.firstIndex(of: upgrade),
				let indexXWS = upgradesXWS.firstIndex(of: upgrade.xws) {
				upgrades.remove(at: index)
				upgradesXWS.remove(at: indexXWS)
			}
			
			removeInvalidUpgrades()
			
			SquadStore.shared.saveSquad(self.squad, syncWithCloud: syncWithCloud)
			DispatchQueue.main.async {
				NotificationCenter.default.post(name: .squadStoreDidRemoveUpgradeFromMember, object: self)
				NotificationCenter.default.post(name: .squadStoreDidUpdateSquad, object: self.squad)
			}
		}
		
		func removeInvalidUpgrades(shouldNotify: Bool = false, notify: Bool = false) {
			var invalidUpgrade: Upgrade? = nil
			
			for upgrade in upgrades {
				guard validity(of: upgrade, replacing: upgrade) == .valid else {
					invalidUpgrade = upgrade
					break
				}
			}
			
			if let invalidUpgrade = invalidUpgrade,
				let index = upgrades.firstIndex(of: invalidUpgrade),
				let indexXWS = upgradesXWS.firstIndex(of: invalidUpgrade.xws){
				upgrades.remove(at: index)
				upgradesXWS.remove(at: indexXWS)
				removeInvalidUpgrades(shouldNotify: shouldNotify, notify: true)
			}
			
			if shouldNotify, notify {
				DispatchQueue.main.async {
					NotificationCenter.default.post(name: .squadStoreDidRemoveUpgradeFromMember, object: self)
					NotificationCenter.default.post(name: .squadStoreDidUpdateSquad, object: self.squad)
				}
			}
		}
		
		enum UpgradeValidity {
			case valid
			case alreadyEquipped
			case slotsNotAvailable
			case limitExceeded
			case restrictionsNotMet
			case notHyperspace
		}
		
		func validity(of upgrade: Upgrade, replacing: Upgrade?) -> UpgradeValidity {
			// Ensure the any restrictions of the upgrade are met
			if let restrictionSets = upgrade.restrictions {
				checkingRestrictionSets: for restrictionSet in restrictionSets {
					guard restrictionSet.restrictions.isEmpty == false else {
						continue
					}
					
					for restriction in restrictionSet.restrictions {
						switch restriction {
						case .factions(let factions):
							if factions.contains(squad.faction) {
								continue checkingRestrictionSets
							}
							
						case .action(let action):
							if allActions.contains(where: {
								$0.type == action.type &&
									(action.difficulty == nil || $0.difficulty == action.difficulty)
							}) {
								continue checkingRestrictionSets
							}
							
						case .ships(let ships):
							if ships.contains(where: {
								$0 == pilot.ship!.xws
							}) {
								continue checkingRestrictionSets
							}
							
						case .sizes(let sizes):
							if sizes.contains(where: {
								$0 == pilot.ship!.size
							}) {
								continue checkingRestrictionSets
							}
							
						case .names(let names):
							for name in names {
								if squad.members.contains(where: {
									$0.pilot.name == name ||
										$0.upgrades.contains(where: { $0.name == name })
								}) {
									continue checkingRestrictionSets
								}
							}
							
						case .arcs(let arcs):
							for arc in arcs {
								if pilot.ship!.stats.map({ $0.arc }).compactMap({ $0 }).contains(arc) {
									continue checkingRestrictionSets
								}
							}
							
						case .forceSides(let forceSides):
							for forceSide in forceSides {
								if allForceSides.contains(forceSide) {
									continue checkingRestrictionSets
								}
							}
							
						case .equipped(let upgradeTypes):
							for upgradeType in upgradeTypes {
								guard upgrades.contains(where: { $0.frontSide.slots.contains(upgradeType) }) else {
									return .restrictionsNotMet
								}
							}

							continue checkingRestrictionSets
							
						case .solitary:
							if let replacing = replacing,
								replacing.frontSide.type == upgrade.frontSide.type {
								continue checkingRestrictionSets
							}
							
							for member in squad.members {
								guard member.upgrades.contains(where: { $0.frontSide.slots.contains(upgrade.frontSide.type) }) == false else {
										return .restrictionsNotMet
								}
							}
							
							continue checkingRestrictionSets
							
						case .nonLimited:
							if pilot.limited == 0 {
								continue checkingRestrictionSets
							}
						}
					}
					
					return .restrictionsNotMet
				}
			}
			
			// Make sure the upgrade is Hyperspace
			if squad.isHyperspaceOnly, upgrade.hyperspace != true {
				return .notHyperspace
			}
			
			// Ensure the the pilot has the correct upgrade slots available for the upgrade
			var availablelots = upgrades.reduce(allSlots) { availablelots, upgrade in
				if upgrade == replacing {
					return availablelots
				}
				
				return upgrade.frontSide.slots.reduce(availablelots) {
					var availablelots = $0
					if let index = availablelots.index(of: $1) {
						availablelots.remove(at: index)
					}
					return availablelots
				}
			}
			
			for slot in upgrade.frontSide.slots {
				guard let index = availablelots.index(of: slot) else {
					return .slotsNotAvailable
				}
				availablelots.remove(at: index)
			}
			
			// Make sure the card limit is not exceeded
			switch squad.limitStatus(for: upgrade) {
			case .met:
				if upgrade == replacing {
					break
				} else {
					fallthrough
				}
			case .exceeded:
				return .limitExceeded
			case .available:
				break
			}
			
			// A pilot can never have two of the same upgrade
			guard upgrade == replacing || upgrades.contains(upgrade) == false else {
				return .alreadyEquipped
			}
			
			return .valid
		}
	}
}

extension Squad.Member: Hashable {
	static func == (lhs: Squad.Member, rhs: Squad.Member) -> Bool {
		return lhs.uuid == rhs.uuid
	}
	
	public func hash(into hasher: inout Hasher) {
		uuid.hash(into: &hasher)
	}
}

extension Squad.Member {
	var allSlots: [Upgrade.UpgradeType] {
		var upgradeSlots = upgrades.reduce(pilot.slots ?? [], {
			$1.sides.reduce($0, {
				guard let grants = $1.grants else {
					return $0
				}
				
				return grants.reduce($0, {
					switch $1 {
					case .slot(let slot, let amount):
						switch amount {
						case 1:
							return $0 + [slot]
						case -1:
							var slots = $0
							if let index = slots.firstIndex(of: slot) {
								slots.remove(at: index)
							}
							return slots
						default:
							return $0
						}
					default:
						return $0
					}
				})
			})
		})
		
		if pilot.shipAbility?.name == "Weapon Hardpoint" {
			let hardpointUpgrades: [Upgrade.UpgradeType] = [.cannon, .torpedo, .missile]
			if let equippedHardpointUpgrade = upgrades.first(where: { $0.sides.contains(where: { hardpointUpgrades.contains($0.type) })}) {
				upgradeSlots.append(equippedHardpointUpgrade.frontSide.type)
			} else {
				upgradeSlots.append(contentsOf: hardpointUpgrades)
			}
		}
		
		return upgradeSlots
	}
	
	var allActions: [Action] {
		return upgrades.reduce(ship.actions, {
			$1.sides.reduce($0, {
				guard let grants = $1.grants else {
					return $0
				}
				
				return grants.reduce($0, {
					switch $1 {
					case .action(let action):
						return $0 + [action]
					default:
						return $0
					}
				})
			})
		})
	}
	
	var allForceSides: [Force.Side] {
		return upgrades.reduce([pilot.force?.side].compactMap({ $0 }).flatMap({ $0 }), {
			$1.sides.reduce($0, {
				guard let grants = $1.grants else {
					return $0
				}
				
				return grants.reduce($0, {
					switch $1 {
					case .force(let force):
						guard let side = force.side else {
							fallthrough
						}
						return $0 + side
					default:
						return $0
					}
				})
			})
		})
	}
	
}
