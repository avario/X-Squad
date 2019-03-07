//
//  SquadCloudStore.swift
//  X-Squad
//
//  Created by Avario on 03/03/2019.
//  Copyright © 2019 Avario. All rights reserved.
//
// Handles syncing squads to iCloud.

import Foundation
import CloudKit
import UIKit

class SquadCloudStore {
	
	static let shared = SquadCloudStore()
	
	private let database: CKDatabase
	
	private init() {
		let container = CKContainer.default()
		
		// Squads are saved to the user's private database
		database = container.privateCloudDatabase		
	}
	
	var didSubscribeToChanges: Bool = false
	
	// Notifications will be sent to the device when any of the user's squads updates.
	public func subscribeToChanges() {
		guard didSubscribeToChanges == false else {
			return
		}
		
		database.fetchAllSubscriptions { (subscriptions, error) in
			if let error = error {
				print(error)
			}
			
			guard let subscriptions = subscriptions else {
				return
			}
			
			guard subscriptions.contains(where: { $0.subscriptionID == "SquadsSubscription"}) else {
				let subscription = CKQuerySubscription(
					recordType: "Squad",
					predicate: NSPredicate(value: true),
					subscriptionID: "SquadsSubscription",
					options: [
						.firesOnRecordCreation,
						.firesOnRecordUpdate,
						.firesOnRecordDeletion])
				
				let info = CKQuerySubscription.NotificationInfo()
				info.shouldSendContentAvailable = true
				subscription.notificationInfo = info
				
				self.database.save(subscription) { (subscription, error) in
					if let error = error {
						print(error)
					}
					
					self.didSubscribeToChanges = true
				}
				
				return
			}
			
			self.didSubscribeToChanges = true
		}
	}
	
	// This is called when the device receives a remote notification from iCloud.
	public func handleNotification(userInfo: [AnyHashable : Any], fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
		let notification = CKQueryNotification(fromRemoteNotificationDictionary: userInfo)
		
		guard let recordID = notification.recordID else {
			completionHandler(.failed)
			return
		}
		
		switch notification.queryNotificationReason {
		case .recordCreated, .recordUpdated:
			database.fetch(withRecordID: recordID) { (record, error) in
				if let error = error {
					print(error)
				}
				
				guard let record = record else {
					completionHandler(.failed)
					return
				}
				
				self.syncRecord(record)
				completionHandler(.newData)
			}
			
		case .recordDeleted:
			guard
				let uuid = UUID(uuidString: recordID.recordName),
				let squad = SquadStore.shared.squads.first(where: { $0.uuid == uuid }) else {
					completionHandler(.failed)
					break
			}
			
			SquadStore.shared.delete(squad: squad, syncWithCloud: false)
			completionHandler(.noData)
		}
	}
	
	var lastSync: Date = .distantPast
	
	public func syncRecordsIfNeeded() {
		// Sync if more than 15 minutes has passed since the last sync
		if Date().timeIntervalSince(lastSync) > 15 * 60 {
			syncRecords()
		}
	}
	
	// This syncs the local store with the iCloud database.
	public func syncRecords() {
		let query = CKQuery(recordType: "Squad", predicate: NSPredicate(value: true))
		
		// Fetch all of the user's squads from iCloud.
		database.perform(query, inZoneWith: nil) { results, error in
			if let error = error {
				print(error)
			}
			
			self.lastSync = Date()
			
			guard let results = results else {
				return
			}
			
			for record in results {
				self.syncRecord(record)
			}
			
			for squad in SquadStore.shared.squads {
				let squadRecord = results.first(where: { $0.recordID.recordName == squad.uuid.uuidString })
				
				if squad.savedToCloud {
					guard squadRecord != nil else {
						// If the squad was previously saved to iCloud but now isn't there, it must have been deleted.
						SquadStore.shared.delete(squad: squad, syncWithCloud: false)
						continue
					}
				} else if squadRecord == nil {
					// Save any squads to iCloud that haven't been saved already.
					self.createOrUpdateSquad(squad)
				} else {
					squad.savedToCloud = true
					SquadStore.shared.save()
				}
			}
		}
	}
	
	func syncRecord(_ record: CKRecord) {
		// Get the data from the record and decode it to a squad.
		if let data = record["data"] as? Data,
			let recordSquad = try? JSONDecoder().decode(Squad.self, from: data) {
			
			if let existingSquad = SquadStore.shared.squads.first(where: { $0.uuid == recordSquad.uuid }) {
				// If the recorded squad was updated more recently than the local one, update the local squad.
				if existingSquad.lastUpdatedDate < recordSquad.lastUpdatedDate {
					existingSquad.update(from: recordSquad)
					
					SquadStore.shared.save()
					
					DispatchQueue.main.async {
						NotificationCenter.default.post(name: .squadStoreDidUpdateSquad, object: existingSquad)
					}
				} else if existingSquad.lastUpdatedDate > recordSquad.lastUpdatedDate  {
					// If the local squad was updated more recently, save it to the cloud.
					saveSquad(existingSquad, to: record)
				}
			} else {
				SquadStore.shared.add(squad: recordSquad)
			}
		}
	}
	
	// Update an existing record or create a new one and save it to iCloud.
	func saveSquad(_ squad: Squad, to record: CKRecord) {
		record["data"] = try? JSONEncoder().encode(squad)
		
		database.save(record) {
			(record, error) in
			if let error = error {
				print(error)
			} else {
				squad.savedToCloud = true
				SquadStore.shared.save()
			}
		}
	}
	
	func createOrUpdateSquad(_ squad: Squad) {
		// Query iCloud for an existing record.
		let recordID = CKRecord.ID(recordName: squad.uuid.uuidString)
		database.fetch(withRecordID: recordID) { (record, error) in
			if let cloudError = error as? CKError,
				cloudError.code == CKError.unknownItem {
				// If no record exists, create a new one.
				let recordID = CKRecord.ID(recordName: squad.uuid.uuidString)
				let record = CKRecord(recordType: "Squad", recordID: recordID)
				self.saveSquad(squad, to: record)
				
			} else if let record = record {
				// Save the squad to the existing record.
				self.saveSquad(squad, to: record)
				
			} else if let error = error {
				print(error)
			}
		}
	}
	
	func deleteSquad(_ squad: Squad) {
		let recordID = CKRecord.ID(recordName: squad.uuid.uuidString)
		database.delete(withRecordID: recordID) { (id, error) in
			if let error = error {
				print(error)
			}
		}
	}
	
}
