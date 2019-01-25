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
	
	let name: String?
	let description: String?
	let obstacles: [XWS.Obstacle]?
	let vendor: XWS.Vendor?
	
	init(faction: Faction, members: [Member] = [], name: String? = nil, description: String? = nil, obstacles: [XWS.Obstacle]? = nil, vendor: XWS.Vendor? = nil) {
		self.uuid = UUID()
		self.faction = faction
		self.members = members
		
		self.name = name
		self.description = description
		self.obstacles = obstacles
		self.vendor = vendor
	}
	
	var pointCost: Int {
		return members.reduce(0, { $0 + $1.pointCost })
	}
	
	@discardableResult func addMember(for pilot: Pilot) -> Member {
		let member = Member(ship: pilot.ship!, pilot: pilot)
		members.append(member)
		members.sort(by: { Squad.rankPilots($0.pilot, $1.pilot) })
		
		SquadStore.save()
		NotificationCenter.default.post(name: .squadStoreDidAddMemberToSquad, object: self)
		NotificationCenter.default.post(name: .squadStoreDidUpdateSquad, object: self)
		
		return member
	}
	
	func remove(member: Member) {
		if let index = members.firstIndex(of: member) {
			members.remove(at: index)
		}
		
		for member in members {
			member.removeInValidUpgrades(shouldNotify: true)
		}
		
		SquadStore.save()
		NotificationCenter.default.post(name: .squadStoreDidRemoveMemberFromSquad, object: self)
		NotificationCenter.default.post(name: .squadStoreDidUpdateSquad, object: self)
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
