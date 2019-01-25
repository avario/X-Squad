//
//  DataStore.swift
//  X-Squad
//
//  Created by Avario on 22/01/2019.
//  Copyright © 2019 Avario. All rights reserved.
//

import Foundation

class DataStore {
	
	private static var dataDirectory: URL {
		let resourceDirectory = Bundle.main.resourceURL!
		return resourceDirectory.appendingPathComponent("data")
	}
	
	private static var shipsDirectory: URL {
		return dataDirectory.appendingPathComponent("pilots")
	}
	
	private static var upgradesDirectory: URL {
		return dataDirectory.appendingPathComponent("upgrades")
	}
	
	private static func data(in directory: URL) -> [Data] {
		var data: [Data] = []
		
		let enumerator = FileManager.default.enumerator(at: directory, includingPropertiesForKeys: [])!
		for case let fileURL as URL in enumerator {
			if fileURL.pathExtension == "json" {
				let fileData = try! Data(contentsOf: fileURL)
				data.append(fileData)
			}
		}
		
		return data
	}
	
	static let ships = loadShips()
	
	private static func loadShips() -> [Ship] {
		return data(in: shipsDirectory).map({ (data) -> Ship in
			return try! JSONDecoder().decode(Ship.self, from: data)
		})
	}
	
	static let upgrades = loadUpgrades()
	
	private static func loadUpgrades() -> [Upgrade] {
		return data(in: upgradesDirectory).map({ (data) -> [Upgrade] in
			return try! JSONDecoder().decode([Upgrade].self, from: data)
		}).flatMap({ $0 })
	}
	
	static var allCards: [Card] = (ships.map({ $0.pilots }).flatMap({ $0 }) as [Card]) + (upgrades as [Card])
	
	static func ship(for xws: XWSID) -> Ship? {
		return ships.first(where: { $0.xws == xws })
	}
	
	static func pilot(for xws: XWSID) -> Pilot? {
		return ships.reduce([]) { $0 + $1.pilots }.first(where: { $0.xws == xws })
	}
	
	static func upgrade(for xws: XWSID) -> Upgrade? {
		return upgrades.first(where: { $0.xws == xws })!
	}
	
	private init() { }
}

extension Pilot {
	var ship: Ship? {
		return DataStore.ships.first(where: { $0.pilots.contains(self) })
	}
}
