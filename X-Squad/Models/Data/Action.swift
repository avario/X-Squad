//
//  Action.swift
//  X-Squad
//
//  Created by Avario on 22/01/2019.
//  Copyright © 2019 Avario. All rights reserved.
//

import Foundation

class Action: Codable {
	let type: ActionType
	let difficulty: Difficulty?
	let linked: Action?
	
	enum ActionType: String, Codable {
		case boost = "Boost"
		case focus = "Focus"
		case evade = "Evade"
		case targetLock = "Lock"
		case barrelRoll = "Barrel Roll"
		case reinforce = "Reinforce"
		case cloak = "Cloak"
		case coordinate = "Coordinate"
		case calculate = "Calculate"
		case jam = "Jam"
		case reload = "Reload"
		case slam = "SLAM"
		case rotate = "Rotate Arc"
	}
	
	enum Difficulty: String, Codable {
		case white = "White"
		case red = "Red"
		case purple = "Purple"
	}
}
