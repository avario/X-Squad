//
//  Game.swift
//  X-Squad
//
//  Created by Avario on 13/02/2019.
//  Copyright © 2019 Avario. All rights reserved.
//

import Foundation

class Game: Codable {
	let uuid = UUID()

	let squad: Squad
	let memberStates: [UUID: MemberState]

	init(squad: Squad) {
		let squadCopy = squad.copy()
		self.squad = squadCopy
		
		var memberStates = [UUID: MemberState]()
		for (index, member) in squadCopy.members.enumerated() {
			memberStates[member.uuid] = MemberState(number: index + 1, member: member)
		}
		
		self.memberStates = memberStates
	}
	
	class MemberState: Codable {
		let number: Int
		let hullTokens: [Token]
		let shieldTokens: [Token]
		let forceTokens: [Token]
		let chargeTokens: [Token]
		
		let upgradeStates: [XWSID: UpgradeState]
		
		init(number: Int, member: Squad.Member) {
			self.number = number
			
			var numberOfHull = member.ship.stats.first(where: { $0.type == .hull })?.value ?? 0
			var numberOfShields = member.ship.stats.first(where: { $0.type == .shields })?.value ?? 0
			var numberOfForce = member.pilot.force?.value ?? 0
			let numberOfCharges = member.pilot.charges?.value ?? 0
			
			for upgrade in member.upgrades {
				if let force = upgrade.frontSide.force?.value {
					numberOfForce += force
				}
				
				guard let grants = upgrade.frontSide.grants else {
					continue
				}
				
				for grant in grants {
					switch grant {
					case .stat(let type, let value):
						switch type {
						case .shields:
							numberOfShields += value
						case .hull:
							numberOfHull += value
						default:
							break
						}
					default:
						continue
					}
				}
			}
			
			self.hullTokens = (0 ..< numberOfHull).map { _ in Token() }
			self.shieldTokens = (0 ..< numberOfShields).map { _ in Token() }
			self.forceTokens = (0 ..< numberOfForce).map { _ in Token() }
			self.chargeTokens = (0 ..< numberOfCharges).map { _ in Token() }
			
			var upgradeStates = [XWSID: UpgradeState]()
			for upgrade in member.upgrades {
				upgradeStates[upgrade.xws] = UpgradeState(upgrade: upgrade)
			}
			
			self.upgradeStates = upgradeStates
		}
		
		class UpgradeState: Codable {
			let chargeTokens: [Token]
			
			init(upgrade: Upgrade) {
				let numberOfCharges = upgrade.frontSide.charges?.value ?? 0
				self.chargeTokens = (0 ..< numberOfCharges).map { _ in Token() }
			}
		}
	}

	class Token: Codable {
		var isActive: Bool = true
	}

}

extension Squad {
	func copy() -> Squad {
		return Squad(faction: faction, members: members.map({ Member(ship: $0.ship, pilot: $0.pilot, upgrades: $0.upgrades) }))
	}
}
