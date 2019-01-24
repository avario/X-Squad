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
}
