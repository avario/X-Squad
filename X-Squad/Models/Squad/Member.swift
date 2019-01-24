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
		
		var ship: Ship
		var pilot: Pilot
		var upgrades: [Upgrade]
		
		init(ship: Ship, pilot: Pilot) {
			self.uuid = UUID()
			self.ship = ship
			self.pilot = pilot
			self.upgrades = []
		}
		
		var squad: Squad? {
			return SquadStore.squads.first(where: { $0.members.contains(self) })
		}
		
		var pointCost: Int {
			return upgrades.reduce(pilot.cost, { $0 + $1.pointCost(for: self) })
		}
		
		var upgradeSlots: [Upgrade.UpgradeType] {
			var upgradeSlots = upgrades.reduce(pilot.slots, {
				$1.sides.reduce($0, {
					guard let grants = $1.grants else {
						return $0
					}
					
					return grants.reduce($0, {
						switch $1.type {
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
					upgradeSlots.append(equippedHardpointUpgrade.primarySide.type)
				} else {
					upgradeSlots.append(contentsOf: hardpointUpgrades)
				}
			}
			
			return upgradeSlots
		}
		
		var actions: [Action] {
			return upgrades.reduce(ship.actions, {
				$1.sides.reduce($0, {
					guard let grants = $1.grants else {
						return $0
					}
					
					return grants.reduce($0, {
						switch $1.type {
						case .action(let action):
							return $0 + [action]
						default:
							return $0
						}
					})
				})
			})
		}
		
		func addUpgrade(_ upgrade: Upgrade) {
			upgrades.append(upgrade)
			
			removeInValidUpgrades()
			
			let upgradeSlots = self.upgradeSlots
			
			upgrades.sort { (lhs, rhs) -> Bool in
				let lhsType = lhs.primarySide.type
				let rhsType = rhs.primarySide.type
				
				guard let lhsIndex = upgradeSlots.firstIndex(of: lhsType),
					let rhsIndex = upgradeSlots.firstIndex(of: rhsType) else {
						return false
				}
				
				if lhsType == rhsType {
					return lhs.name < rhs.name
				} else {
					return lhsIndex < rhsIndex
				}
			}
			
			SquadStore.save()
			NotificationCenter.default.post(name: .squadStoreDidAddUpgradeToMember, object: self)
			NotificationCenter.default.post(name: .squadStoreDidUpdateSquad, object: squad)
		}
		
		func remove(upgrade: Upgrade) {
			if let index = upgrades.firstIndex(of: upgrade) {
				upgrades.remove(at: index)
			}
			
			removeInValidUpgrades()
			
			SquadStore.save()
			NotificationCenter.default.post(name: .squadStoreDidRemoveUpgradeFromMember, object: self)
			NotificationCenter.default.post(name: .squadStoreDidUpdateSquad, object: squad)
		}
		
		func removeInValidUpgrades(shouldNotify: Bool = false, notify: Bool = false) {
			var invalidUpgrade: Upgrade? = nil
			
			for upgrade in upgrades {
				guard validity(of: upgrade, replacing: upgrade) == .valid else {
					invalidUpgrade = upgrade
					break
				}
			}
			
			if let invalidUpgrade = invalidUpgrade,
				let index = upgrades.firstIndex(of: invalidUpgrade) {
				upgrades.remove(at: index)
				removeInValidUpgrades(shouldNotify: shouldNotify, notify: true)
			}
			
			if shouldNotify, notify {
				NotificationCenter.default.post(name: .squadStoreDidRemoveUpgradeFromMember, object: self)
				NotificationCenter.default.post(name: .squadStoreDidUpdateSquad, object: squad)
			}
		}
		
		enum UpgradeValidity {
			case valid
			case alreadyEquipped
			case slotsNotAvailable
			case limitExceeded
			case restrictionsNotMet
		}
		
		func validity(of upgrade: Upgrade, replacing: Upgrade?) -> UpgradeValidity {
			return .valid
			
			// Ensure the any restrictions of the upgrade are met
//			for restrictionSet in restrictions {
//				var passedSet = false
//
//				for restriction in restrictionSet {
//					switch restriction.type {
//					case .faction:
//						if let factionID = restriction.parameters.id,
//							squad.faction.rawValue == factionID {
//							passedSet = true
//						}
//
//					case .action:
//						if let actionID = restriction.parameters.id,
//							let action = pilot.allActions.first(where: { $0.baseType.rawValue == actionID }) {
//							if let sideEffect = restriction.parameters.sideEffectName {
//								switch sideEffect {
//								case .stress:
//									if action.baseSideEffect == .stress {
//										passedSet = true
//									}
//								case .none:
//									if action.baseSideEffect == nil {
//										passedSet = true
//									}
//								}
//							} else {
//								passedSet = true
//							}
//						}
//
//					case .shipType:
//						if let shipID = restriction.parameters.id,
//							pilot.card.shipType?.rawValue == shipID {
//							passedSet = true
//						}
//
//					case .shipSize:
//						if let shipSize = restriction.parameters.shipSizeName {
//							switch shipSize {
//							case .small:
//								if pilot.card.shipSize == .small {
//									passedSet = true
//								}
//							case .medium:
//								if pilot.card.shipSize == .medium {
//									passedSet = true
//								}
//							case .large:
//								if pilot.card.shipSize == .large {
//									passedSet = true
//								}
//							}
//						}
//
//					case .cardIncluded:
//						if let cardID = restriction.parameters.id {
//							for pilot in squad.pilots {
//								if pilot.card.id == cardID ||
//									pilot.upgrades.contains(where: { $0.card.id == cardID }) {
//									passedSet = true
//									break
//								}
//							}
//						}
//
//					case .arc:
//						if let arcID = restriction.parameters.id,
//							pilot.card.statistics.contains(where: { $0.type.rawValue == arcID }) {
//							passedSet = true
//						}
//
//					case .forceSide:
//						if let forceSide = restriction.parameters.forceSideName {
//							switch forceSide {
//							case .light:
//								if pilot.card.forceSide == .light {
//									passedSet = true
//								}
//							case .dark:
//								if pilot.card.forceSide == .dark || pilot.upgrades.contains(where: { $0.card.id == 361 /* Maul */ }) {
//									passedSet = true
//								}
//							}
//						}
//					}
//
//					if passedSet { break }
//				}
//
//				guard passedSet else { return .restrictionsNotMet }
//			}
//			
//			// Ensure the the pilot has the correct upgrade slots available for the upgrade
//			var availableUpgradeSlots = pilot.upgrades.reduce(pilot.allUpgradeSlots) { availableUpgrades, upgrade in
//				if upgrade.uuid == currentUpgrade?.uuid {
//					return availableUpgrades
//				}
//				
//				var availableUpgrades = availableUpgrades
//				for upgradeType in upgrade.card.upgradeTypes {
//					if let index = availableUpgrades.index(of: upgradeType) {
//						availableUpgrades.remove(at: index)
//					}
//				}
//				return availableUpgrades
//			}
//			
//			for upgradeType in upgradeTypes {
//				guard let index = availableUpgradeSlots.index(of: upgradeType) else {
//					return .slotsNotAvailable
//				}
//				availableUpgradeSlots.remove(at: index)
//			}
//			
//			// Unique cards can only be in a squad once
//			if isUnique {
//				for pilot in squad.pilots {
//					if pilot.card.name == name {
//						return .uniqueInUse
//					}
//					if let uniqueUpgrade = pilot.upgrades.first(where: { $0.card.name == name }), uniqueUpgrade.uuid != currentUpgrade?.uuid {
//						return .uniqueInUse
//					}
//				}
//			}
//			
//			// A pilot can never have two of the same upgrade
//			for upgrade in pilot.upgrades {
//				if upgrade.card == self, upgrade.uuid != currentUpgrade?.uuid {
//					return .alreadyEquipped
//				}
//			}
//			
//			return .valid
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
