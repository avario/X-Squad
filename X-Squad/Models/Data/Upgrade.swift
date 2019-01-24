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
	let xws: String
	let sides: [Side]
	let cost: Cost
	
	enum Cost: Codable {
		case constant(Int)
		case variable(Variable)
		
		struct Variable: Codable {
			let variable: VariableType
			let values: [String: Int]
			
			enum VariableType: String, Codable {
				case size
				case agility
			}
		}
		
		init(from decoder: Decoder) throws {
			let values = try decoder.container(keyedBy: CodingKeys.self)
			
			if let value = try? values.decode(Int.self, forKey: .value) {
				self = .constant(value)
			} else {
				self = .variable(try Variable(from: decoder))
			}
		}
		
		func encode(to encoder: Encoder) throws {
			var container = encoder.container(keyedBy: CodingKeys.self)
			
			switch self {
			case .constant(let value):
				try container.encode(value, forKey: .value)
				
			case .variable(let variable):
				try container.encode(variable.variable, forKey: .variable)
				try container.encode(variable.values, forKey: .values)
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
		let image: URL
		let artwork: URL?
		let ffg: Int
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
		
		struct Grant: Codable {
			let type: GrantType
			
			enum GrantType {
				case action(Action)
				case slot(UpgradeType, Int)
				case force(Force)
				case stat(Ship.Stat.StatType)
				
				enum Name: String, Codable {
					case action
					case slot
					case force
					case stat
				}
			}
			
			init(from decoder: Decoder) throws {
				let values = try decoder.container(keyedBy: CodingKeys.self)
				let typeName = try values.decode(GrantType.Name.self, forKey: .type)
				
				switch typeName {
				case .action:
					let action = try values.decode(Action.self, forKey: .value)
					self.type = .action(action)
					
				case .slot:
					let slot = try values.decode(UpgradeType.self, forKey: .value)
					let amount = try values.decode(Int.self, forKey: .amount)
					self.type = .slot(slot, amount)
					
				case .force:
					let force = try values.decode(Force.self, forKey: .value)
					self.type = .force(force)
					
				case .stat:
					let statType = try values.decode(Ship.Stat.StatType.self, forKey: .value)
					self.type = .stat(statType)
				}
			}
			
			func encode(to encoder: Encoder) throws {
				var container = encoder.container(keyedBy: CodingKeys.self)
				
				switch self.type {
				case .action(let action):
					try container.encode(GrantType.Name.action, forKey: .type)
					try container.encode(action, forKey: .value)
					
				case .slot(let slot, let amount):
					try container.encode(GrantType.Name.slot, forKey: .type)
					try container.encode(slot, forKey: .value)
					try container.encode(amount, forKey: .amount)
					
				case .force(let force):
					try container.encode(GrantType.Name.force, forKey: .type)
					try container.encode(force, forKey: .value)
					
				case .stat(let stat):
					try container.encode(GrantType.Name.stat, forKey: .type)
					try container.encode(stat, forKey: .value)
				}
			}
			
			enum CodingKeys: String, CodingKey {
				case type
				case value
				case amount
			}
		}
	}
	
	enum UpgradeType: String, Codable {
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
	}
}

extension Upgrade: Hashable {
	var primarySide: Upgrade.Side {
		return sides.first!
	}
	
	static func == (lhs: Upgrade, rhs: Upgrade) -> Bool {
		return lhs.xws == rhs.xws
	}
	
	public func hash(into hasher: inout Hasher) {
		xws.hash(into: &hasher)
	}
}
