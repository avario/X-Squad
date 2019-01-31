//
//  Faction.swift
//  X-Squad
//
//  Created by Avario on 22/01/2019.
//  Copyright © 2019 Avario. All rights reserved.
//

import Foundation

enum Faction: String, CaseIterable, Codable {
	case rebelAlliance = "Rebel Alliance"
	case galacticEmpire = "Galactic Empire"
	case scumAndVillainy = "Scum and Villainy"
	case resistance = "Resistance"
	case firstOrder = "First Order"
	case galacticRepublic = "Galactic Republic"
	case separatistAlliance = "Separatist Alliance"
	
	var isReleased: Bool {
		switch self {
		case .rebelAlliance,
			 .galacticEmpire,
			 .scumAndVillainy,
			 .resistance,
			 .firstOrder:
			return true
			
		case .galacticRepublic,
			 .separatistAlliance:
			return false
		}
	}
	
	static var releasedFactions: [Faction] {
		return allCases.filter({ $0.isReleased })
	}
}
