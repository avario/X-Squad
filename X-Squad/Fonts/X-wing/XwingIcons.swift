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
			return "R"
		case .calculate:
			return "a"
		case .reload:
			return "="
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
			return "Z"
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
		case .separatistAlliance:
			return "."
		}
	}
}

extension Ship {
	
	var characterCode: String? {
		switch xws {
		case "modifiedyt1300lightfreighter":
			return "m"
		case "starviperclassattackplatform":
			return "v"
		case "scurrgh6bomber":
			return "H"
		case "yt2400lightfreighter":
			return "o"
		case "auzituckgunship":
			return "@"
		case "kihraxzfighter":
			return "r"
		case "sheathipedeclassshuttle":
			return "%"
		case "quadrijettransferspacetug":
			return "q"
		case "firesprayclasspatrolcraft":
			return "f"
		case "tielnfighter":
			return "F"
		case "btla4ywing":
			return "y"
		case "tieadvancedx1":
			return "A"
		case "alphaclassstarwing":
			return "&"
		case "ut60duwing":
			return "u"
		case "tieskstriker":
			return "T"
		case "asf01bwing":
			return "b"
		case "tieddefender":
			return "D"
		case "tiesabomber":
			return "B"
		case "tiecapunisher":
			return "N"
		case "aggressorassaultfighter":
			return "i"
		case "g1astarfighter":
			return "n"
		case "vcx100lightfreighter":
			return "G"
		case "yv666lightfreighter":
			return "t"
		case "tieadvancedv1":
			return "R"
		case "lambdaclasst4ashuttle":
			return "l"
		case "tiephphantom":
			return "P"
		case "vt49decimator":
			return "d"
		case "tieagaggressor":
			return "`"
		case "btls8kwing":
			return "k"
		case "arc170starfighter":
			return "c"
		case "attackshuttle":
			return "g"
		case "t65xwing":
			return "x"
		case "hwk290lightfreighter":
			return "h"
		case "rz1awing":
			return "a"
		case "fangfighter":
			return "M"
		case "z95af4headhunter":
			return "z"
		case "m12lkimogilafighter":
			return "K"
		case "ewing":
			return "e"
		case "tieininterceptor":
			return "I"
		case "lancerclasspursuitcraft":
			return "L"
		case "tiereaper":
			return "V"
		case "m3ainterceptor":
			return "s"
		case "jumpmaster5000":
			return "p"
		case "customizedyt1300lightfreighter":
			return "W"
		case "escapecraft":
			return "X"
		case "tiefofighter":
			return "O"
		case "tiesffighter":
			return "S"
		case "upsilonclassshuttle":
			return "U"
		case "tievnsilencer":
			return "$"
		case "t70xwing":
			return "w"
		case "rz2awing":
			return "E"
		case "mg100starfortress":
			return "Z"
		case "modifiedtielnfighter":
			return "C"
		case "scavengedyt1300":
			return "Y"
		default:
			return nil
		}
	}
}

extension Ship.Maneuver.Bearing {
	var characterCode: String {
		switch self {
		case .straight:
			return "8"
		case .bankLeft:
			return "7"
		case .bankRight:
			return "9"
		case .turnLeft:
			return "4"
		case .turnRight:
			return "6"
		case .koiogranTurn:
			return "2"
		case .segnorsLoopLeft:
			return "1"
		case .segnorsLoopRight:
			return "3"
		case .tallonRollLeft:
			return ":"
		case .tallonRollRight:
			return ";"
		case .stationary:
			return "5"
		case .reverse:
			return "K"
		case .reverseBankLeft:
			return "J"
		case .reverseBankRight:
			return "L"
		}
	}
}

extension Ship.Size {
	var characterCode: String {
		switch self {
		case.small:
			return "Á"
		case .medium:
			return "Â"
		case .large:
			return "Ã"
		}
	}
}
