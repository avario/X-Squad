//
//  Upgrade.swift
//  X-Squad
//
//  Created by Avario on 22/01/2019.
//  Copyright © 2019 Avario. All rights reserved.
//

import Foundation

class Upgrade: Codable {
	
	let name: String
	let limited: Int
	let xws: XWSID
	let sides: [Side]
	let cost: Cost?
	let restrictions: [RestrictionsSet]?
	let hyperspace: Bool?
	
	struct RestrictionsSet: Codable {
		
		let restrictions: [Restriction]
		
		enum Restriction {
			case factions([Faction])
			case names([String])
			case sizes([Ship.Size])
			case ships([XWSID])
			case forceSides([Force.Side])
			case arcs([Ship.Stat.Arc])
			case action(Action)
			case equipped([UpgradeType])
			case solitary
			case nonLimited
		}
		
		init(from decoder: Decoder) throws {
			let values = try decoder.container(keyedBy: CodingKeys.self)
						
			self.restrictions = CodingKeys.allCases.reduce([]) { restrictions, codingKey in
				switch codingKey {
				case .factions:
					if let factions = try? values.decode([Faction].self, forKey: .factions) {
						return restrictions + [.factions(factions)]
					}
				case .names:
					if let names = try? values.decode([String].self, forKey: .names) {
						return restrictions + [.names(names)]
					}
				case .sizes:
					if let sizes = try? values.decode([Ship.Size].self, forKey: .sizes) {
						return restrictions + [.sizes(sizes)]
					}
				case .ships:
					if let ships = try? values.decode([XWSID].self, forKey: .ships) {
						return restrictions + [.ships(ships)]
					}
				case .forceSides:
					if let forceSides = try? values.decode([Force.Side].self, forKey: .forceSides) {
						return restrictions + [.forceSides(forceSides)]
					}
				case .arcs:
					if let arcs = try? values.decode([Ship.Stat.Arc].self, forKey: .arcs) {
						return restrictions + [.arcs(arcs)]
					}
				case .action:
					if let action = try? values.decode(Action.self, forKey: .action) {
						return restrictions + [.action(action)]
					}
				case .equipped:
					if let upgradeTypes = try? values.decode([UpgradeType].self, forKey: .equipped) {
						return restrictions + [.equipped(upgradeTypes)]
					}
				case .solitary:
					if (try? values.decode(Bool.self, forKey: .solitary)) == true {
						return restrictions + [.solitary]
					}
				case .nonLimited:
					if (try? values.decode(Bool.self, forKey: .nonLimited)) == true {
						return restrictions + [.nonLimited]
					}
				}
				
				return restrictions
			}
		}
		
		func encode(to encoder: Encoder) throws {
			var container = encoder.container(keyedBy: CodingKeys.self)
			
			for restriction in restrictions {
				switch restriction {
				case .factions(let factions):
					try container.encode(factions, forKey: .factions)
					
				case .names(let names):
					try container.encode(names, forKey: .names)
					
				case .sizes(let sizes):
					try container.encode(sizes, forKey: .sizes)
					
				case .ships(let ships):
					try container.encode(ships, forKey: .ships)
					
				case .forceSides(let forceSides):
					try container.encode(forceSides, forKey: .forceSides)
					
				case .arcs(let arcs):
					try container.encode(arcs, forKey: .arcs)
					
				case .action(let action):
					try container.encode(action, forKey: .action)
					
				case .equipped(let upgradeTypes):
					try container.encode(upgradeTypes, forKey: .equipped)
					
				case .solitary:
					try container.encode(true, forKey: .solitary)
					
				case .nonLimited:
					try container.encode(true, forKey: .nonLimited)
				}
			}
		}
		
		enum CodingKeys: String, CodingKey, CaseIterable {
			case factions
			case names
			case sizes
			case ships
			case forceSides = "force_side"
			case arcs
			case action
			case equipped
			case solitary
			case nonLimited = "non-limited"
		}
	}
	
	enum Cost: Codable {
		case constant(Int)
		case variable(Variable)
		
		enum Variable {
			case size([Ship.Size: Int])
			case agility([Agility: Int])
			case initiative([Initiative: Int])
			
			enum VariableType: String, Codable {
				case size
				case agility
				case initiative
			}
			
			enum Agility: String, CodingKey, Codable, CaseIterable {
				case zero = "0"
				case one = "1"
				case two = "2"
				case three = "3"
			}
			
			enum Initiative: String, CodingKey, Codable, CaseIterable {
				case zero = "0"
				case one = "1"
				case two = "2"
				case three = "3"
				case four = "4"
				case five = "5"
				case six = "6"
			}
		}
		
		init(from decoder: Decoder) throws {
			let values = try decoder.container(keyedBy: CodingKeys.self)
			
			if let value = try? values.decode(Int.self, forKey: .value) {
				self = .constant(value)
			} else {
				let variable = try values.decode(Variable.VariableType.self, forKey: .variable)
				switch variable {
				case .size:
					let sizeValuesContainer = try values.nestedContainer(keyedBy: Ship.Size.self, forKey: .values)
					var sizeValues = [Ship.Size: Int]()
					for size in Ship.Size.allCases {
						let sizeValue = try sizeValuesContainer.decode(Int.self, forKey: size)
						sizeValues[size] = sizeValue
					}
					
					self = .variable(.size(sizeValues))
				case .agility:
					let agilityValuesContainer = try values.nestedContainer(keyedBy: Variable.Agility.self, forKey: .values)
					var agilityValues = [Variable.Agility: Int]()
					for agility in Variable.Agility.allCases {
						let agilityValue = try agilityValuesContainer.decode(Int.self, forKey: agility)
						agilityValues[agility] = agilityValue
					}
					
					self = .variable(.agility(agilityValues))
					
				case .initiative:
					let initiativeValuesContainer = try values.nestedContainer(keyedBy: Variable.Initiative.self, forKey: .values)
					var initiativeValues = [Variable.Initiative: Int]()
					for initiative in Variable.Initiative.allCases {
						let initiativeValue = try initiativeValuesContainer.decode(Int.self, forKey: initiative)
						initiativeValues[initiative] = initiativeValue
					}
					
					self = .variable(.initiative(initiativeValues))
				}
			}
		}
		
		func encode(to encoder: Encoder) throws {
			var container = encoder.container(keyedBy: CodingKeys.self)
			
			switch self {
			case .constant(let value):
				try container.encode(value, forKey: .value)
				
			case .variable(let variable):
				switch variable {
				case .size(let sizeValues):
					try container.encode(Variable.VariableType.size.rawValue, forKey: .variable)
					try container.encode(sizeValues, forKey: .values)
					
				case .agility(let agilityValues):
					try container.encode(Variable.VariableType.agility.rawValue, forKey: .variable)
					try container.encode(agilityValues, forKey: .values)
					
				case .initiative(let initiativeValues):
					try container.encode(Variable.VariableType.initiative.rawValue, forKey: .variable)
					try container.encode(initiativeValues, forKey: .values)
				}
				
			}
		}
		
		enum CodingKeys: String, CodingKey {
			case value
			case variable
			case values
		}
	}
	
	struct Side: Codable {
		let title: String
		let type: UpgradeType
		let ability: String?
		let text: String?
		let slots: [UpgradeType]
		let image: URL?
		let artwork: URL?
		let ffg: Int?
		let actions: [Action]?
		let grants: [Grant]?
		let force: Force?
		let charges: Charges?
		let attack: Attack?
		
		struct Attack: Codable {
			let arc: Ship.Stat.Arc
			let value: Int
			let minrange: Int
			let maxrange: Int
			let ordnance: Bool
		}
		
		enum Grant: Codable {
			case action(Action)
			case slot(UpgradeType, Int)
			case force(Force)
			case stat(Ship.Stat.StatType, Int)
			
			enum Name: String, Codable {
				case action
				case slot
				case force
				case stat
			}
			
			init(from decoder: Decoder) throws {
				let values = try decoder.container(keyedBy: CodingKeys.self)
				let name = try values.decode(Grant.Name.self, forKey: .type)
				
				switch name {
				case .action:
					let action = try values.decode(Action.self, forKey: .value)
					self = .action(action)
					
				case .slot:
					let slot = try values.decode(UpgradeType.self, forKey: .value)
					let amount = try values.decode(Int.self, forKey: .amount)
					self = .slot(slot, amount)
					
				case .force:
					let force = try values.decode(Force.self, forKey: .value)
					self = .force(force)
					
				case .stat:
					let statType = try values.decode(Ship.Stat.StatType.self, forKey: .value)
					let amount = try values.decode(Int.self, forKey: .amount)
					self = .stat(statType, amount)
				}
			}
			
			func encode(to encoder: Encoder) throws {
				var container = encoder.container(keyedBy: CodingKeys.self)
				
				switch self {
				case .action(let action):
					try container.encode(Grant.Name.action, forKey: .type)
					try container.encode(action, forKey: .value)
					
				case .slot(let slot, let amount):
					try container.encode(Grant.Name.slot, forKey: .type)
					try container.encode(slot, forKey: .value)
					try container.encode(amount, forKey: .amount)
					
				case .force(let force):
					try container.encode(Grant.Name.force, forKey: .type)
					try container.encode(force, forKey: .value)
					
				case .stat(let stat, let amount):
					try container.encode(Grant.Name.stat, forKey: .type)
					try container.encode(stat, forKey: .value)
					try container.encode(amount, forKey: .amount)
				}
			}
			
			enum CodingKeys: String, CodingKey {
				case type
				case value
				case amount
			}
		}
	}
	
	enum UpgradeType: String, Codable, CaseIterable {
		case talent = "Talent"
		case sensor = "Sensor"
		case cannon = "Cannon"
		case turret = "Turret"
		case torpedo = "Torpedo"
		case missile = "Missile"
		case crew = "Crew"
		case astromech = "Astromech"
		case device = "Device"
		case illicit = "Illicit"
		case modification = "Modification"
		case title = "Title"
		case gunner = "Gunner"
		case force = "Force Power"
		case configuration = "Configuration"
		case tech = "Tech"
		case tacticalRelay = "Tactical Relay"
		
		enum Priority: Int {
			case talent, force
			case crew, gunner
			case astromech, tech, sensor, illicit, tacticalRelay
			case cannon, turret, torpedo, missile, device
			case modification, title, configuration
		}
		
		var priority: Priority {
			switch self {
			case .talent:			return .talent
			case .sensor:			return .sensor
			case .cannon:			return .cannon
			case .turret:			return .turret
			case .torpedo:			return .torpedo
			case .missile:			return .missile
			case .crew:				return .crew
			case .astromech:		return .astromech
			case .device:			return .device
			case .illicit:			return .illicit
			case .modification:		return .modification
			case .title:			return .title
			case .gunner:			return .gunner
			case .force:			return .force
			case .configuration:	return .configuration
			case .tech:				return .tech
			case .tacticalRelay:	return .tacticalRelay
			}
		}
	}
}

extension Upgrade: Hashable {
	
	var frontSide: Upgrade.Side {
		return sides.first!
	}
	
	var backSide: Upgrade.Side? {
		if sides.count == 1 {
			return nil
		}
		return sides.last
	}
	
	static func == (lhs: Upgrade, rhs: Upgrade) -> Bool {
		return  lhs.xws == rhs.xws
			&& lhs.frontSide.type == rhs.frontSide.type
	}
	
	public func hash(into hasher: inout Hasher) {
		xws.hash(into: &hasher)
		frontSide.type.hash(into: &hasher)
	}
}
