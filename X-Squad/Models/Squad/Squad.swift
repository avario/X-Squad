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
	
	init(faction: Faction) {
		self.uuid = UUID()
		self.faction = faction
		self.members = []
	}
	
	var pointCost: Int {
		return members.reduce(0, { $0 + $1.pointCost })
	}
	
	@discardableResult func addMember(for pilot: Pilot) -> Member {
		let member = Member(ship: pilot.ship, pilot: pilot)
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
			return $0.cost > $1.cost
		}
		return $0.initiative > $1.initiative
	}
	
	enum PilotValidity {
		case valid
		case limitExceeded
	}
	
	func validity(of pilot: Pilot) -> PilotValidity {
		#warning("")
		return .valid
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
