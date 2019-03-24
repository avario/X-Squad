//
//  DataStore.swift
//  X-Squad
//
//  Created by Avario on 22/01/2019.
//  Copyright © 2019 Avario. All rights reserved.
//
// Loads X-Wing Data 2 JSON files into model objects.

import Foundation
import CloudKit
import Zip

extension Notification.Name {
	static let dataStoreShowImagesDidChange = Notification.Name("dataStoreShowImagesDidChange")
}

class DataStore {
	
	static let shared = DataStore()
	
	private(set) var ships: [Ship]
	private(set) var upgrades: [Upgrade]
	
	private init() {
		guard let downloadedDataPath = DataStore.downloadedDataPath?.appendingPathComponent("data"),
			let downloadedShips = try? DataStore.loadShips(from: downloadedDataPath),
			let downloadedUpgrades = try? DataStore.loadUpgrades(from: downloadedDataPath),
			downloadedShips.isEmpty == false,
			downloadedUpgrades.isEmpty == false else {
			
				let bundledDirectory = Bundle.main.resourceURL!.appendingPathComponent("data")
				ships = try! DataStore.loadShips(from: bundledDirectory)
				upgrades = try! DataStore.loadUpgrades(from: bundledDirectory)
				
				return
		}
		
		ships = downloadedShips
		upgrades = downloadedUpgrades
	}
	
	static var lastUpdateDate: Date {
		get { return UserDefaults.standard.object(forKey: "lastUpdateDate") as? Date ?? .distantPast }
		set { UserDefaults.standard.set(newValue, forKey: "lastUpdateDate") }
	}
	
	static var downloadedDataPath: URL? {
		get { return UserDefaults.standard.url(forKey: "downloadedDataPath") }
		set { UserDefaults.standard.set(newValue, forKey: "downloadedDataPath") }
	}
	
	static var showImages: Bool {
		get {
			let appVersion = Bundle.main.infoDictionary!["CFBundleShortVersionString"] as! String
			return UserDefaults.standard.bool(forKey: "showImages\(appVersion)")
		}
		set {
			let appVersion = Bundle.main.infoDictionary!["CFBundleShortVersionString"] as! String
			UserDefaults.standard.set(newValue, forKey: "showImages\(appVersion)")
			
			DispatchQueue.main.async {
				NotificationCenter.default.post(name: .dataStoreShowImagesDidChange, object: nil)
			}
		}
	}
	
	func updateIfNeeded() {
		let container = CKContainer.default()
		let database = container.publicCloudDatabase
		
		let appVersion = Bundle.main.infoDictionary!["CFBundleShortVersionString"] as! String
		
		let predicate = NSPredicate(
			format: "(modificationDate > %@) AND (version == %@)",
			argumentArray: [DataStore.lastUpdateDate, appVersion])
		let query = CKQuery(recordType: "Data", predicate: predicate)
		query.sortDescriptors = [NSSortDescriptor(key: "modificationDate", ascending: false)]
		database.perform(query, inZoneWith: nil) { (records, error) in
			if let error = error {
				print(error)
				return
			}
			
			guard
				let records = records,
				let mostRecentRecord = records.first,
			 	let mostRecentData = mostRecentRecord["data"] as? CKAsset else {
				return
			}
			
			do {
				let data = try Data(contentsOf: mostRecentData.fileURL)
				let fileURL = FileManager.default.temporaryDirectory.appendingPathComponent("data.zip")
				try data.write(to: fileURL)
				
				let zipPath = try Zip.quickUnzipFile(fileURL)
				
				DataStore.downloadedDataPath = zipPath
				DataStore.lastUpdateDate = mostRecentRecord.modificationDate ?? Date()
				
				let dataPath = zipPath.appendingPathComponent("data")
				self.ships = try DataStore.loadShips(from: dataPath)
				self.upgrades = try DataStore.loadUpgrades(from: dataPath)
				
				CardSearch.shared.updateSearchIndices()
				
				if let showImages = mostRecentRecord["showImages"] as? NSNumber {
					DataStore.showImages = showImages.boolValue
				}
			} catch {
				print(error)
			}
		}
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
	
	private static func loadShips(from directory: URL) throws -> [Ship] {
		let shipsDirectory = directory.appendingPathComponent("pilots")
		
		return try data(in: shipsDirectory).map({ (data) -> Ship in
			return try JSONDecoder().decode(Ship.self, from: data)
		})
	}
	
	private static func loadUpgrades(from directory: URL) throws -> [Upgrade] {
		let upgradesDirectory = directory.appendingPathComponent("upgrades")
		
		return try data(in: upgradesDirectory).map({ (data) -> [Upgrade] in
			return try JSONDecoder().decode([Upgrade].self, from: data)
		}).flatMap({ $0 }).filter({ $0.frontSide.image != nil })
	}
	
	var allCards: [Card] {
		return (ships.map({ $0.pilots }).flatMap({ $0 }) as [Card]) + (upgrades as [Card])
	}
	
	func ship(for xws: XWSID) -> Ship? {
		return ships.first(where: { $0.xws == xws })
	}
	
	func pilot(for xws: XWSID) -> Pilot? {
		return ships.reduce([]) { $0 + $1.pilots }.first(where: { $0.xws == xws })
	}
	
	func upgrade(for xws: XWSID) -> Upgrade? {
		return upgrades.first(where: { $0.xws == xws })!
	}
}

extension Pilot {
	var ship: Ship? {
		return DataStore.shared.ships.first(where: { $0.pilots.contains(self) })
	}
}
