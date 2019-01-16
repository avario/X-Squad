//
//  SquadStore.swift
//  X-Squad
//
//  Created by Avario on 10/01/2019.
//  Copyright © 2019 Avario. All rights reserved.
//

import Foundation

extension Notification.Name {
	static let squadStoreDidAddSquad = Notification.Name("squadStoreDidAddSquad")
	static let squadStoreDidDeleteSquad = Notification.Name("squadStoreDidDeleteSquad")
	
	static let squadStoreDidAddPilotToSquad = Notification.Name("squadStoreDidAddPilotToSquad")
	static let squadStoreDidRemovePilotFromSquad = Notification.Name("squadStoreDidRemovePilotFromSquad")
	
	static let squadStoreDidUpdateSquad = Notification.Name("squadStoreDidUpdateSquad")
	
	static let squadStoreDidAddUpgradeToPilot = Notification.Name("squadStoreDidAddUpgradeToPilot")
	static let squadStoreDidRemoveUpgradeFromPilot = Notification.Name("squadStoreDidRemoveUpgradeFromPilot")
}

class SquadStore {
	
	private init() { }
	
	public private(set) static var squads: [Squad] = loadSquads()
	
	private static var fileURL: URL {
		let fileManager = FileManager.default
		let documentDirectory = try! fileManager.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false)
		return documentDirectory.appendingPathComponent("Xwing_Squads")
	}
	
	public static func save() {
		let fileData = try! JSONEncoder().encode(squads)
		try! fileData.write(to: fileURL)
	}
	
	private static func loadSquads() -> [Squad] {
		guard let fileData = try? Data(contentsOf: fileURL),
			let savedSquads = try? JSONDecoder().decode([Squad].self, from: fileData) else {
				return []
		}
		return savedSquads
	}
	
	public static func add(squad: Squad) {
		squads.append(squad)
		save()
		NotificationCenter.default.post(name: .squadStoreDidAddSquad, object: squad)
	}
	
	public static func delete(squad: Squad) {
		guard let index = squads.index(of: squad) else {
			return
		}
		squads.remove(at: index)
		save()
		NotificationCenter.default.post(name: .squadStoreDidDeleteSquad, object: squad)
	}
	
}
