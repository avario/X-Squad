//
//  XWS.swift
//  X-Squad
//
//  Created by Avario on 24/01/2019.
//  Copyright © 2019 Avario. All rights reserved.
//

import Foundation

struct XWS: Codable {
	
	static let currentVersion: String = "2.0.0"
	
	let name: String?
	let faction: Faction
	let points: Int?
	let version: String
	let description: String?
	let obstacles: [Obstacle]?
	let pilots: [Pilot]
	let vendor: Vendor?
	
	enum Faction: String, Codable {
		case rebelalliance, galacticempire, scumandvillainy, firstorder, resistance, galacticrepublic, separatistalliance
	}
	
	enum Obstacle: String, Codable {
		case coreasteroid0, coreasteroid1, coreasteroid2, coreasteroid3, coreasteroid4, coreasteroid5
		case core2asteroid0, core2asteroid1, core2asteroid2, core2asteroid3, core2asteroid4, core2asteroid5
		case yt2400debris0, yt2400debris1, yt2400debris2
		case vt49decimatordebris0, vt49decimatordebris1, vt49decimatordebris2
	}
	
	struct Pilot: Codable {
		let id: String
		let upgrades: [String: [String]]
		let points: Int?
		
		enum Upgrade: String, Codable {
			case talent
			case sensor
			case cannon
			case turret
			case torpedo
			case missile
			case crew
			case astromech
			case device
			case illicit
			case modification
			case title
			case gunner
			case force_power = "force-power"
			case configuration
			case tech
			case tactical_relay = "tactical-relay"
		}
	}
	
	struct Vendor: Codable {
		let ffg: FFG?
		
		struct FFG: Codable {
			let builder_url: URL?
		}
	}
	
}
