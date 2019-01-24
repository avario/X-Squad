//
//  Force.swift
//  X-Squad
//
//  Created by Avario on 22/01/2019.
//  Copyright © 2019 Avario. All rights reserved.
//

import Foundation

struct Force: Codable {
	let value: Int?
	let recovers: Int?
	let side: [Side]?
	
	enum Side: String, Codable {
		case light = "light"
		case dark = "dark"
	}
}
