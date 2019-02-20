//
//  XWSConverter.swift
//  X-Squad
//
//  Created by Avario on 24/01/2019.
//  Copyright © 2019 Avario. All rights reserved.
//

import Foundation

extension Squad {
	convenience init(xws: XWS) {
		let faction: Faction
		switch xws.faction {
		case .rebelalliance:
			faction = .rebelAlliance
		case .galacticempire:
			faction = .galacticEmpire
		case .scumandvillainy:
			faction = .scumAndVillainy
		case .firstorder:
			faction = .firstOrder
		case .resistance:
			faction = .resistance
		case .galacticrepublic:
			faction = .galacticRepublic
		case .separatistalliance:
			faction = .separatistAlliance
		}
		
		let members = xws.pilots.map({ pilot -> Member? in
			guard let pilotCard = DataStore.pilot(for: pilot.id),
			 	let ship = pilotCard.ship else {
				return nil
			}
			
			let upgrades = pilot.upgrades.reduce([Upgrade?]()) { upgrades, upgrade in
				return upgrades + upgrade.value.map({ DataStore.upgrade(for: $0) })
			}.compactMap({ $0 })
			
			return Member(ship: ship, pilot: pilotCard, upgrades: upgrades)
		}).compactMap({ $0 })
		
		self.init(faction: faction, members: members, name: xws.name, description: xws.description, obstacles: xws.obstacles, vendor: xws.vendor)
	}
}

extension XWS {
	init(squad: Squad) {
		name = squad.name ?? "X-Squad"
		description = squad.description
		points = nil
		version = nil//XWS.currentVersion
		obstacles = squad.obstacles
		vendor = squad.vendor
		pilots = squad.members.map(Pilot.init(member:))
		
		let faction: Faction
		switch squad.faction {
		case .rebelAlliance:
			faction = .rebelalliance
		case .galacticEmpire:
			faction = .galacticempire
		case .scumAndVillainy:
			faction = .scumandvillainy
		case .firstOrder:
			faction = .firstorder
		case .resistance:
			faction = .resistance
		case .galacticRepublic:
			faction = .galacticrepublic
		case .separatistAlliance:
			faction = .separatistalliance
		}
		
		self.faction = faction
	}
}

typealias DataUpgrade = Upgrade

extension XWS.Pilot {
	init(member: Squad.Member) {
		id = member.pilot.xws
		points = nil
		ship = member.ship.xws
		
		var upgrades = [String: [String]]()
		for upgradeType in DataUpgrade.UpgradeType.allCases {
			
			let upgradesForSlot = member.upgrades.filter({ $0.frontSide.type == upgradeType })
			guard upgradesForSlot.isEmpty == false else {
				continue
			}
			
			let upgrade: Upgrade
			switch upgradeType {
			case .talent:
				upgrade = .talent
			case .sensor:
				upgrade = .sensor
			case .cannon:
				upgrade = .cannon
			case .turret:
				upgrade = .turret
			case .torpedo:
				upgrade = .torpedo
			case .missile:
				upgrade = .missile
			case .crew:
				upgrade = .crew
			case .astromech:
				upgrade = .astromech
			case .device:
				upgrade = .device
			case .illicit:
				upgrade = .illicit
			case .modification:
				upgrade = .modification
			case .title:
				upgrade = .title
			case .gunner:
				upgrade = .gunner
			case .force:
				upgrade = .force_power
			case .configuration:
				upgrade = .configuration
			case .tech:
				upgrade = .tech
			case .tacticalRelay:
				upgrade = .tactical_relay
			}
			
			upgrades[upgrade.rawValue] = upgradesForSlot.map({ $0.xws })
		}
		
		self.upgrades = upgrades
	}
}
