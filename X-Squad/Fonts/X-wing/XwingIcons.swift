//
//  XwingIcons.swift
//  X-Squad
//
//  Created by Avario on 08/01/2019.
//  Copyright © 2019 Avario. All rights reserved.
//

import Foundation

extension Action.ActionType {
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

extension Upgrade.UpgradeType {
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
		case .tacticalRelay:
			return "t" // This is wrong...
		}
	}
}

extension Faction {
	var characterCode: String {
		switch self {
		case .resistance:
			return "!"
		case .rebelAlliance:
			return "!"
		case .galacticEmpire:
			return "@"
		case .firstOrder:
			return "+"
		case .scumAndVillainy:
			return "#"
		case .galacticRepublic:
			return "/"
		}
	}
}

extension Ship {
	
	var characterCode: String {
		switch type {
		case .modifiedYT1300:
			return "m"
		case .starViper:
			return "v"
		case .scurrgH6Bomber:
			return "H"
		case .YT2400:
			return "o"
		case .auzituckGunship:
			return "@"
		case .kihraxzFighter:
			return "r"
		case .sheathipede:
			return "%"
		case .quadrijetSpacetug:
			return "q"
		case .firespray:
			return "f"
		case .TIElnFighter:
			return "F"
		case .BTLA4Ywing:
			return "y"
		case .TIEAdvancedx1:
			return "A"
		case .alphaclassStarWing:
			return "&"
		case .UT60DUwing:
			return "u"
		case .TIEskStriker:
			return "T"
		case .ASF01Bwing:
			return "b"
		case .TIEDDefender:
			return "D"
		case .TIEsaBomber:
			return "B"
		case .TIEcsPunisher:
			return "N"
		case .aggressor:
			return "i"
		case .G1AStarfighter:
			return "n"
		case .VCX100:
			return "G"
		case .YV666:
			return "t"
		case .TIEAdvancedv1:
			return "R"
		case .lambdaShuttle:
			return "l"
		case .TIEphPhantom:
			return "P"
		case .VT49Decimator:
			return "d"
		case .TIEagAggressor:
			return "`"
		case .BTLS8Kwing:
			return "k"
		case .ARC170Starfighter:
			return "c"
		case .attackShuttle:
			return "g"
		case .T65Xwing:
			return "x"
		case .HWK290:
			return "h"
		case .RZ1Awing:
			return "a"
		case .fangFighter:
			return "M"
		case .Z95AF4Headhunter:
			return "z"
		case .M12LKimogila:
			return "K"
		case .Ewing:
			return "e"
		case .TIEInterceptor:
			return "I"
		case .lancerPursuitCraft:
			return "L"
		case .TIEReaper:
			return "V"
		case .M3AInterceptor:
			return "s"
		case .jumpMaster5000:
			return "p"
		case .customizedYT1300:
			return "W"
		case .escapeCraft:
			return "X"
		case .TIEfoFighter:
			return "O"
		case .TIEsfFighter:
			return "S"
		case .upsilonclassCommandShuttle:
			return "U"
		case .TIEvnSilencer:
			return "$"
		case .T70Xwing:
			return "w"
		case .RZ2Awing:
			return "a"
		case .MG100StarFortress:
			return "Z"
		case .modifiedTIEln:
			return "F"
		case .scavengedYT1300:
			return "m"
		}
	}
}

