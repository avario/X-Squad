//
//  XwingIcons.swift
//  X-Squad
//
//  Created by Avario on 08/01/2019.
//  Copyright © 2019 Avario. All rights reserved.
//

import Foundation

extension Card.Action.ActionType {
	
	var characterCode: String {
		switch self {
		case .focus:
			return "f"
		case .targetLock:
			return "l"
		case .evade:
			return "e"
		case .barrelRoll:
			return "r"
		case .boost:
			return "b"
		case .slam:
			return "s"
		case .cloak:
			return "k"
		case .coordinate:
			return "o"
		case .jam:
			return "j"
		case .reinforce:
			return "i"
		case .rotate:
			return "a"
		case .calculate:
			return "a" // ?
		case .reload:
			return "d" // ?
		}
	}
	
}

extension Card.UpgradeType {
	
	var characterCode: String {
		switch self {
		case .talent:
			return "E"
		case .astromech:
			return "A"
		case .torpedo:
			return "P"
		case .missile:
			return "M"
		case .cannon:
			return "C"
		case .turret:
			return "U"
		case .device:
			return "B"
		case .crew:
			return "W"
		case .sensor:
			return "S"
		case .modification:
			return "m"
		case .illicit:
			return "I"
		case .tech:
			return "X"
		case .title:
			return "t"
		case .gunner:
			return "Y"
		case .force:
			return "F"
		case .configuration:
			return "n"
		case .special:
			return "ê"
		}
	}
	
}
