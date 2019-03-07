//
//  SquadStore.swift
//  X-Squad
//
//  Created by Avario on 10/01/2019.
//  Copyright © 2019 Avario. All rights reserved.
//
// Persitantly stores user's squads.

import Foundation
import CloudKit

extension Notification.Name {
	static let squadStoreDidAddSquad = Notification.Name("squadStoreDidAddSquad")
	static let squadStoreDidDeleteSquad = Notification.Name("squadStoreDidDeleteSquad")
	static let squadStoreDidUpdateSquad = Notification.Name("squadStoreDidUpdateSquad")
	
	static let squadStoreDidAddMemberToSquad = Notification.Name("squadStoreDidAddMemberToSquad")
	static let squadStoreDidRemoveMemberFromSquad = Notification.Name("squadStoreDidRemoveMemberFromSquad")
	
	static let squadStoreDidAddUpgradeToMember = Notification.Name("squadStoreDidAddUpgradeToMember")
	static let squadStoreDidRemoveUpgradeFromMember = Notification.Name("squadStoreDidRemoveUpgradeFromMember")
}

class SquadStore {
	
	static let shared = SquadStore()
	
	private init() { }
	
	public private(set) lazy var squads: [Squad] = loadSquads()
	
	private static var fileURL: URL {
		let fileManager = FileManager.default
		let documentDirectory = try! fileManager.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false)
		return documentDirectory.appendingPathComponent("Xwing_Squads")
	}
	
	public func saveSquad(_ squad: Squad, syncWithCloud: Bool = true) {
		squad.lastUpdatedDate = Date()
		save()
		
		if syncWithCloud {
			SquadCloudStore.shared.createOrUpdateSquad(squad)
		}
	}
	
	public func save() {
		let fileData = try! JSONEncoder().encode(squads)
		try! fileData.write(to: SquadStore.fileURL)
	}
	
	private let squadSort: (Squad, Squad) -> Bool = {
		if $0.createdDate == $1.createdDate {
			return $0.uuid.uuidString < $1.uuid.uuidString
		}
		return $0.createdDate < $1.createdDate
	}
	
	private func loadSquads() -> [Squad] {
		guard let fileData = try? Data(contentsOf: SquadStore.fileURL),
			let savedSquads = try? JSONDecoder().decode([Squad].self, from: fileData) else {
				return []
		}
		return savedSquads.sorted(by: squadSort)
	}
	
	public func add(squad: Squad) {
		squads.append(squad)
		squads.sort(by: squadSort)
		saveSquad(squad)
		DispatchQueue.main.async {
			NotificationCenter.default.post(name: .squadStoreDidAddSquad, object: squad)
		}
	}
	
	public func delete(squad: Squad, syncWithCloud: Bool = true) {
		guard let index = squads.index(of: squad) else {
			return
		}
		squads.remove(at: index)
		save()
		
		if syncWithCloud {
			SquadCloudStore.shared.deleteSquad(squad)
		}
		
		DispatchQueue.main.async {
			NotificationCenter.default.post(name: .squadStoreDidDeleteSquad, object: squad)
		}
	}
	
}
