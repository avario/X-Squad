//
//  Squad.swift
//  X-Squad
//
//  Created by Avario on 10/01/2019.
//  Copyright © 2019 Avario. All rights reserved.
//

import Foundation

class Squad: Codable {
	let uuid: UUID
	
	let faction: Faction
	private(set) var members: [Member]
	private var isHyperspace: Bool?
	private var lastUpdated: Date?
	private var created: Date?
	private var isSavedToCloud: Bool?
	
	var name: String?
	var description: String?
	var obstacles: [XWS.Obstacle]?
	var vendor: XWS.Vendor?
	
	var isHyperspaceOnly: Bool {
		get {
			return isHyperspace ?? false
		}
		set {
			isHyperspace = newValue
			
			removeInvalidCards()
			
			SquadStore.shared.saveSquad(self)
		}
	}
	
	var lastUpdatedDate: Date {
		get {
			return lastUpdated ?? .distantPast
		}
		set {
			lastUpdated = newValue
		}
	}
	
	var savedToCloud: Bool {
		get {
			return isSavedToCloud ?? false
		}
		set {
			isSavedToCloud = newValue
		}
	}
	
	var createdDate: Date {
		get {
			return created ?? .distantPast
		}
		set {
			created = newValue
		}
	}
	
	init(faction: Faction, members: [Member] = [], name: String? = nil, description: String? = nil, obstacles: [XWS.Obstacle]? = nil, vendor: XWS.Vendor? = nil) {
		self.uuid = UUID()
		self.created = Date()
		self.lastUpdated = Date()
		self.faction = faction
		self.members = members
		self.isHyperspace = false
		
		self.name = name
		self.description = description
		self.obstacles = obstacles
		self.vendor = vendor
	}
	
	var pointCost: Int {
		return members.reduce(0, { $0 + $1.pointCost })
	}
	
	func update(from record: Squad) {
		// Delete members no longer in the record
		for member in members {
			if record.members.contains(member) == false {
				remove(member: member, syncWithCloud: false)
			}
		}
		
		// Update members
		for recordMember in record.members {
			if let exisitingMember = members.first(where: { $0 == recordMember }) {
				exisitingMember.update(from: recordMember)
			} else {
				add(member: recordMember, syncWithCloud: false)
			}
		}
		
		isHyperspace = record.isHyperspace
		lastUpdated = record.lastUpdated
		
		name = record.name
		description = record.description
		obstacles = record.obstacles
		vendor = record.vendor
	}
	
	@discardableResult func addMember(for pilot: Pilot) -> Member {
		let member = Member(ship: pilot.ship!, pilot: pilot)
		add(member: member)
		
		return member
	}
	
	func add(member: Member, syncWithCloud: Bool = true) {
		members.append(member)
		members.sort(by: { Squad.rankPilots($0.pilot, $1.pilot) })
		
		SquadStore.shared.saveSquad(self, syncWithCloud: syncWithCloud)
		
		DispatchQueue.main.async {
			NotificationCenter.default.post(name: .squadStoreDidAddMemberToSquad, object: self)
			NotificationCenter.default.post(name: .squadStoreDidUpdateSquad, object: self)
		}
	}
	
	func remove(member: Member, syncWithCloud: Bool = true) {
		if let index = members.firstIndex(of: member) {
			members.remove(at: index)
		}
		
		removeInvalidCards()
		
		SquadStore.shared.saveSquad(self, syncWithCloud: syncWithCloud)
		
		DispatchQueue.main.async {
			NotificationCenter.default.post(name: .squadStoreDidRemoveMemberFromSquad, object: self)
			NotificationCenter.default.post(name: .squadStoreDidUpdateSquad, object: self)
		}
	}
	
	private func removeInvalidCards() {
		for member in members {
			if isHyperspaceOnly {
				guard member.pilot.hyperspace == true else {
					remove(member: member)
					removeInvalidCards()
					return
				}
			}
			
			member.removeInvalidUpgrades(shouldNotify: true)
		}
	}
	
	static let rankPilots: (Pilot, Pilot) -> Bool = {
		if $0.initiative == $1.initiative {
			if $0.cost == $1.cost {
				return $0.name > $1.name
			}
			return $0.pointCost() > $1.pointCost()
		}
		return $0.initiative > $1.initiative
	}
	
	enum LimitStatus {
		case available
		case met
		case exceeded
	}
	
	func limitStatus(for card: Card) -> LimitStatus {
		if card.limited > 0 {
			let count = members.reduce(0) {
				var count = $0
				if $1.pilot.name == card.name {
					count += 1
				}
				return $1.upgrades.reduce(count) {
					if $1.name == card.name {
						return $0 + 1
					} else {
						return $0
					}
				}
			}
			
			if count == card.limited {
				return .met
			} else if count > card.limited {
				return .exceeded
			}
		}
		
		return .available
	}
}

extension Squad: Hashable {
	static func == (lhs: Squad, rhs: Squad) -> Bool {
		return lhs.uuid == rhs.uuid
	}
	
	public func hash(into hasher: inout Hasher) {
		uuid.hash(into: &hasher)
	}
}
