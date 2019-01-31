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
	
	var type: ShipType {
		guard let ffg = ffg else {
			return .T65Xwing
		}
		
		return ShipType(rawValue: ffg)!
	}
	
	enum ShipType: Int, Codable {
		case modifiedYT1300 = 1
		case starViper = 3
		case scurrgH6Bomber = 4
		case YT2400 = 5
		case auzituckGunship = 6
		case kihraxzFighter = 7
		case sheathipede = 8
		case quadrijetSpacetug = 9
		case firespray = 10
		case TIElnFighter = 11
		case BTLA4Ywing = 12
		case TIEAdvancedx1 = 13
		case alphaclassStarWing = 14
		case UT60DUwing = 15
		case TIEskStriker = 16
		case ASF01Bwing = 17
		case TIEDDefender = 18
		case TIEsaBomber = 19
		case TIEcsPunisher = 20
		case aggressor = 21
		case G1AStarfighter = 22
		case VCX100 = 23
		case YV666 = 24
		case TIEAdvancedv1 = 25
		case lambdaShuttle = 26
		case TIEphPhantom = 27
		case VT49Decimator = 28
		case TIEagAggressor = 29
		case BTLS8Kwing = 30
		case ARC170Starfighter = 31
		case attackShuttle = 32
		case T65Xwing = 33
		case HWK290 = 34
		case RZ1Awing = 35
		case fangFighter = 36
		case Z95AF4Headhunter = 38
		case M12LKimogila = 39
		case Ewing = 40
		case TIEInterceptor = 41
		case lancerPursuitCraft = 42
		case TIEReaper = 43
		case M3AInterceptor = 44
		case jumpMaster5000 = 45
		case customizedYT1300 = 47
		case escapeCraft = 48
		case TIEfoFighter = 49
		case TIEsfFighter = 50
		case upsilonclassCommandShuttle = 51
		case TIEvnSilencer = 52
		case T70Xwing = 53
		case RZ2Awing = 54
		case MG100StarFortress = 55
		case modifiedTIEln = 56
		case scavengedYT1300 = 57
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
