//
//  CardSearch.swift
//  X-Squad
//
//  Created by Avario on 23/01/2019.
//  Copyright © 2019 Avario. All rights reserved.
//

import Foundation

class CardSearch {
	
	private static let searchIndices = createSearchIndices()
	
	public static func createSearchIndices() -> [SearchIndex] {
		let pilotIndices = DataStore.shared.ships.map({ ship -> [SearchIndex] in
			return ship.pilots.map({ pilot in
				guard pilot.frontImage != nil else {
					return nil
				}
				return SearchIndex(ship: ship, pilot: pilot)
			}).compactMap({ $0 })
		}).flatMap({ $0 })
		
		let upgradeIndices = DataStore.shared.upgrades.map(SearchIndex.init(upgrade:))
		
		return pilotIndices + upgradeIndices
	}
	
	static func searchResults(for term: String) -> [Card] {
		let validSearchTerm = term
			.trimmingCharacters(in: CharacterSet.whitespaces)
			.components(separatedBy: SearchIndex.invalidSearchCharacters)
			.joined()
			.lowercased()
		
		guard validSearchTerm.isEmpty == false else {
			return []
		}
		
		var results: [Card] = []
		
		searchIndexLoop: for index in searchIndices {
			for titleTerm in index.titleTerms {
				if titleTerm.hasPrefix(validSearchTerm) {
					results.insert(index.card, at: 0)
					continue searchIndexLoop
				}
			}
			
			for additionalTerm in index.additionalTerms {
				if additionalTerm.hasPrefix(validSearchTerm) {
					results.append(index.card)
					continue searchIndexLoop
				}
			}
		}
		
		return results
	}
	
	struct SearchIndex {
		let card: Card
		let titleTerms: [String]
		let additionalTerms: [String]
		
		static let invalidSearchCharacters: CharacterSet = {
			var characterSet = CharacterSet.alphanumerics
			characterSet.formUnion(CharacterSet.whitespaces)
			return characterSet.inverted
		}()
		
		init(ship: Ship, pilot: Pilot) {
			self.init(card: pilot, additionalTerms: ship.searchTags)
		}
		
		init(upgrade: Upgrade) {
			self.init(card: upgrade, additionalTerms: upgrade.searchTags)
		}
		
		private init(card: Card, additionalTerms: [String]) {
			self.card = card
			
			var titleTerms: [String] = []
			
			let title = card.name
				.components(separatedBy: SearchIndex.invalidSearchCharacters)
				.joined()
				.lowercased()
			
			titleTerms.append(title)
			
			var titleComponents = title.components(separatedBy: CharacterSet.whitespaces)
			while true {
				titleComponents.removeFirst()
				guard titleComponents.isEmpty == false else {
					break
				}
				titleTerms.append(titleComponents.joined(separator: " "))
			}
			
			self.titleTerms = titleTerms
			self.additionalTerms = additionalTerms
		}
	}
	
}

extension Upgrade {
	
	var searchTags: [String] {
		return sides.map({ side -> [String] in
			switch side.type {
			case .astromech:
				return ["astromech"]
			case .talent:
				return ["talent"]
			case .sensor:
				return ["sensor"]
			case .cannon:
				return ["cannon"]
			case .turret:
				return ["turret"]
			case .torpedo:
				return ["torpedo"]
			case .missile:
				return ["missile"]
			case .crew:
				return ["crew"]
			case .gunner:
				return ["gunner"]
			case .illicit:
				return ["illicit"]
			case .modification:
				return ["modification"]
			case .title:
				return ["title"]
			case .device:
				return ["device"]
			case .force:
				return ["force"]
			case .configuration:
				return ["configuration"]
			case .tech:
				return ["tech"]
			case .tacticalRelay:
				return ["tactical relay"]
			}
		}).flatMap({ $0 })
	}
	
}

extension Ship {
	
	var searchTags: [String] {
		switch self.type {
		case .aggressor:
			return ["aggressor"]
		case .modifiedYT1300:
			return ["modified yt1300", "yt1300"]
		case .starViper:
			return ["starviper", "star viper"]
		case .scurrgH6Bomber:
			return ["scurrgh6bomber"]
		case .YT2400:
			return ["yt2400"]
		case .auzituckGunship:
			return ["auzituck gunship"]
		case .kihraxzFighter:
			return ["kihraxz fighter"]
		case .sheathipede:
			return ["sheathipede"]
		case .quadrijetSpacetug:
			return ["quadrijet spacetug"]
		case .firespray:
			return ["firespray"]
		case .TIElnFighter:
			return ["tieln fighter", "tie fighter"]
		case .BTLA4Ywing:
			return ["btla4 ywing", "ywing"]
		case .TIEAdvancedx1:
			return ["tie advanced x1", "tie x1"]
		case .alphaclassStarWing:
			return ["alphaclass starwing"]
		case .UT60DUwing:
			return ["ut60d uwing", "uwing"]
		case .TIEskStriker:
			return ["tiesk striker", "tie striker", "striker"]
		case .ASF01Bwing:
			return ["asf01 bwing", "bwing"]
		case .TIEDDefender:
			return ["tied defender", "tie defender", "defender"]
		case .TIEsaBomber:
			return ["tiesa bomber", "tie bomber", "bomber"]
		case .TIEcsPunisher:
			return ["tiecs punisher", "tie punisher", "punisher"]
		case .G1AStarfighter:
			return ["g1a starfighter"]
		case .VCX100:
			return ["vcx100"]
		case .YV666:
			return ["yv666"]
		case .TIEAdvancedv1:
			return ["tie advanced v1", "tie v1"]
		case .lambdaShuttle:
			return ["lambda shuttle"]
		case .TIEphPhantom:
			return ["tieph phantom", "tie phantom", "phantom"]
		case .VT49Decimator:
			return ["vt49 decimator", "decimator"]
		case .TIEagAggressor:
			return ["tieag aggressor", "tie aggressor", "aggressor"]
		case .BTLS8Kwing:
			return ["btls8 kwing", "kwing"]
		case .ARC170Starfighter:
			return ["arc170 starfighter"]
		case .attackShuttle:
			return ["attack shuttle"]
		case .T65Xwing:
			return ["t65 xwing", "xwing"]
		case .HWK290:
			return ["hwk290"]
		case .RZ1Awing:
			return ["rz1 awing", "awing"]
		case .fangFighter:
			return ["fang fighter"]
		case .Z95AF4Headhunter:
			return ["z95af4 headhunter", "headhunter"]
		case .M12LKimogila:
			return ["m12l kimogila", "kimogila"]
		case .Ewing:
			return ["ewing"]
		case .TIEInterceptor:
			return ["tie interceptor", "interceptor"]
		case .lancerPursuitCraft:
			return ["lancer pursuit craft"]
		case .TIEReaper:
			return ["tie reaper", "reaper"]
		case .M3AInterceptor:
			return ["m3a interceptor"]
		case .jumpMaster5000:
			return ["jumpmaster 5000"]
		case .customizedYT1300:
			return ["customized yt1300", "yt1300"]
		case .escapeCraft:
			return ["escape craft"]
		case .TIEfoFighter:
			return ["tiefo fighter", "tie fighter"]
		case .TIEsfFighter:
			return ["tiesf fighter", "special forces tie fighter"]
		case .upsilonclassCommandShuttle:
			return ["upsilonclass command shuttle"]
		case .TIEvnSilencer:
			return ["tievn silencer", "tie silencer", "silencer"]
		case .T70Xwing:
			return ["t70 xwing", "xwing"]
		case .RZ2Awing:
			return ["rz2 awing", "awing"]
		case .MG100StarFortress:
			return ["mg100 star fortress"]
		case .modifiedTIEln:
			return ["modified tieln", "tie fighter"]
		case .scavengedYT1300:
			return ["scavenged yt1300", "yt1300"]
		case .unknown:
			return []
		}
	}
	
}
