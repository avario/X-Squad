//
//  Ship.swift
//  X-Squad
//
//  Created by Avario on 22/01/2019.
//  Copyright © 2019 Avario. All rights reserved.
//

import Foundation

typealias XWSID = String

class Ship: Codable {
	
	let name: String
	let xws: XWSID
	let ffg: Int?
	let icon: URL?
	let size: Size
	let faction: Faction
	let dial: [Maneuver]
	let stats: [Stat]
	let actions: [Action]
	let pilots: [Pilot]
	
	struct Stat: Codable {
		
		let type: StatType
		let value: Int
		let arc: Arc?
		
		enum StatType: String, Codable {
			case attack = "attack"
			case agility = "agility"
			case hull = "hull"
			case shields = "shields"
		}
		
		enum Arc: String, Codable {
			case standardFrontArc = "Front Arc"
			case standardRearArc = "Rear Arc"
			case fullFrontArc = "Full Front Arc"
			case fullRearArc = "Full Rare Arc"
			case singleMobileArc = "Single Turret Arc"
			case doubleMobileArd = "Double Turret Arc"
			case bullseye = "Bullseye Arc"
		}
	}
	
	enum Size: String, CodingKey, Codable, CaseIterable {
		case small = "Small"
		case medium = "Medium"
		case large = "Large"
	}
	
	struct Maneuver: Codable {
		let speed: Int
		let bearing: Bearing
		let difficulty: Difficulty
		
		enum Bearing: String, Codable {
			case straight = "F"
			case bankLeft = "B"
			case bankRight = "N"
			case turnLeft = "T"
			case turnRight = "Y"
			case koiogranTurn = "K"
			case segnorsLoopLeft = "L"
			case segnorsLoopRight = "P"
			case tallonRollLeft = "E"
			case tallonRollRight = "R"
			case stationary = "O"
			case reverse = "S"
			case reverseBankLeft = "A"
			case reverseBankRight = "D"
		}
		
		enum Difficulty: String, Codable {
			case blue = "B"
			case white = "W"
			case red = "R"
		}
		
		init(from decoder: Decoder) throws {
			let string = try decoder.singleValueContainer().decode(String.self)
			let values = string.map(String.init)
			
			speed = Int(values[0])!
			bearing = Bearing(rawValue: values[1])!
			difficulty = Difficulty(rawValue: values[2])!
		}
		
		func encode(to encoder: Encoder) throws {
			var container = encoder.singleValueContainer()
			
			let string = String(speed) + bearing.rawValue + difficulty.rawValue
			try container.encode(string)
		}
	}
	
}

extension Ship: Hashable {
	static func == (lhs: Ship, rhs: Ship) -> Bool {
		return lhs.xws == rhs.xws
	}
	
	public func hash(into hasher: inout Hasher) {
		xws.hash(into: &hasher)
	}
}
