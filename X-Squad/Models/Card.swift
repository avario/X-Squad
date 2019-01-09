//
//  Card.swift
//  X-Squad
//
//  Created by Avario on 02/01/2019.
//  Copyright © 2019 Avario. All rights reserved.
//

import Foundation

struct Card: Codable {
	
	let id: Int
	let faction: Faction?
	let cardSetIDs: [Int]
	let type: CardType
	let availableActions: [Action]
	let statistics: [Statistic]
	let availableUpgrades: [UpgradeType]
	let restrictions: [[Restriction]]
	let upgradeTypes: [UpgradeType]
	let weaponRange: String?
	let displayImageURL: URL
	let cardImageURL: URL
	let name: String
	let subtitle: String?
	let abilityText: String
	let cost: String
	let shipAbilityText: String?
	let shipSize: ShipSize?
	let forceSide: ForceSide?
	let initiative: Int?
	let weaponNoBonus: Bool
	let FFGID: String
	let isUnique: Bool
	let shipType: ShipType?
	
	enum CodingKeys: String, CodingKey {
		case id
		case faction = "faction_id"
		case cardSetIDs = "card_set_ids"
		case type = "card_type_id"
		case availableActions = "available_actions"
		case statistics
		case availableUpgrades = "available_upgrades"
		case restrictions
		case upgradeTypes = "upgrade_types"
		case weaponRange = "weapon_range"
		case displayImageURL = "image"
		case cardImageURL = "card_image"
		case name
		case subtitle
		case abilityText = "ability_text"
		case cost
		case shipAbilityText = "ship_ability_text"
		case shipSize = "ship_size"
		case forceSide = "force_side"
		case initiative
		case weaponNoBonus = "weapon_no_bonus"
		case FFGID = "ffg_id"
		case isUnique = "is_unique"
		case shipType = "ship_type"
	}
	
	enum Faction: Int, Codable {
		case rebelAlliance = 1
		case galacticEmpire = 2
		case scumAndVillainy = 3
		case resistance = 4
		case firstOrder = 5
	}
	
	enum CardType: Int, Codable {
		case pilot = 1
		case upgrade = 2
	}
	
	struct Action: Codable {
		
		let id: Int
		let baseType: ActionType
		let linkedType: ActionType?
		let baseSideEffect: SideEffect?
		let linkedSideEffect: SideEffect?
		
		enum CodingKeys: String, CodingKey {
			case id
			case baseType = "base_action_id"
			case linkedType = "related_action_id"
			case baseSideEffect = "base_action_side_effect"
			case linkedSideEffect = "related_action_side_effect"
		}
		
		enum ActionType: Int, Codable {
			case boost = 1
			case focus = 2
			case evade = 3
			case targetLock = 4
			case barrelRoll = 5
			case reinforce = 6
			case cloak = 7
			case coordinate = 8
			case calculate = 9
			case jam = 10
			case reload = 12
			case slam = 13
			case rotate = 14
		}
		
		enum SideEffect: String, Codable {
			case stress = "stress"
		}
	}
	
	struct Statistic: Codable {
		let id: Int
		let type: StatisticType
		let value: String
		let recurring: Bool
		
		enum CodingKeys: String, CodingKey {
			case id
			case type = "statistic_id"
			case value
			case recurring
		}
		
		enum StatisticType: Int, Codable {
			case agility = 1
			case hull = 2
			case shield = 3
			case force = 4
			case charge = 7
			case attackDoubleMobileArc = 8
			case attackFullFrontArc = 9
			case attackStandardFrontArc = 10
			case attackBullseye = 11
			case attackSingleMobileArc = 12
			case attackStandardRearArc = 14
		}
	}
	
	enum UpgradeType: Int, Codable {
		case talent = 1
		case sensor = 2
		case cannon = 3
		case turret = 4
		case torpedo = 5
		case missile = 6
		case crew = 8
		case astromech = 10
		case gunner = 12
		case illicit = 13
		case modification = 14
		case title = 15
		case device = 16
		case force = 17
		case configuration = 18
		case tech = 19
		case special = 999
	}
	
	struct Restriction: Codable {
		let type: RestrictionType
		let parameters: Parameters
		
		enum CodingKeys: String, CodingKey {
			case type
			case parameters = "kwargs"
		}
		
		enum RestrictionType: String, Codable {
			case faction = "FACTION"
			case action = "ACTION"
			case shipType = "SHIP_TYPE"
			case shipSize = "SHIP_SIZE"
			case cardIncluded = "CARD_INCLUDED"
			case arc = "ARC"
			case forceSide = "FORCE_SIDE"
		}
		
		struct Parameters: Codable {
			let id: Int?
			let name: String?
			let sideEffectName: String?
			let rawName: String?
			let shipSizeName: String?
			let forceSideName: String?
			
			enum CodingKeys: String, CodingKey {
				case id = "pk"
				case name
				case sideEffectName = "side_effect_name"
				case rawName = "raw_name"
				case shipSizeName = "ship_size_name"
				case forceSideName = "force_side_name"
			}
		}
	}
	
	enum ShipSize: Int, Codable {
		case small = 1
		case medium = 2
		case large = 3
	}
	
	enum ForceSide: Int, Codable {
		case dark = 1
		case light = 2
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

extension Card: Equatable {
	static func == (lhs: Card, rhs: Card) -> Bool {
		return lhs.id == rhs.id
	}
}
