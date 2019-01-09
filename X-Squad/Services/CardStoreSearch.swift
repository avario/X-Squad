//
//  CardStoreSearch.swift
//  X-Squad
//
//  Created by Avario on 03/01/2019.
//  Copyright © 2019 Avario. All rights reserved.
//

import Foundation

extension CardStore {
	
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
		
		for index in searchIndices {
			for titleTerm in index.titleTerms {
				if titleTerm.hasPrefix(validSearchTerm) {
					results.append(index.card)
					break
				}
			}
		}
		
		for index in searchIndices {
			for typeTerm in index.typeTerms {
				if typeTerm.hasPrefix(validSearchTerm) {
					results.append(index.card)
					break
				}
			}
		}
		
		return results
	}
	
	struct SearchIndex {
		let card: Card
		let titleTerms: [String]
		let typeTerms: [String]
		
		static let invalidSearchCharacters: CharacterSet = {
			var characterSet = CharacterSet.alphanumerics
			characterSet.formUnion(CharacterSet.whitespaces)
			return characterSet.inverted
		}()
		
		init(card: Card) {
			self.card = card
			
			var titleTerms: [String] = []
			
			let title = card.name.components(separatedBy: SearchIndex.invalidSearchCharacters).joined().lowercased()
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
			
			var typeTerms: [String] = []
			
			switch card.type {
			case .pilot:
				guard let shipType = card.shipType else {
					break
				}
				typeTerms.append(contentsOf: shipType.searchTags)
				
			case .upgrade:
				guard let upgradeType = card.upgradeTypes.first else {
					break
				}
				typeTerms.append(contentsOf: upgradeType.searchTags)
			}
			
			self.typeTerms = typeTerms
		}
	}
	
	public static func createSearchIndices(for cards: [Card]) -> [SearchIndex] {
		return cards.map(SearchIndex.init)
	}
	
}

extension Card.UpgradeType {
	
	var searchTags: [String] {
		switch self {
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
		case .special:
			return []
		}
	}
	
}

extension Card.ShipType {
	
	var searchTags: [String] {
		switch self {
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
			return ["tielnfighter", "tie fighter"]
		case .BTLA4Ywing:
			return ["btla4 ywing", "ywing"]
		case .TIEAdvancedx1:
			return ["tie advanced x1", "tie x1"]
		case .alphaclassStarWing:
			return ["alphaclass starwing"]
		case .UT60DUwing:
			return ["ut60d uwing", "uwing"]
		case .TIEskStriker:
			return ["tiesk striker", "tie striker"]
		case .ASF01Bwing:
			return ["asf01 bwing", "bwing"]
		case .TIEDDefender:
			return ["tied defender", "tie defender"]
		case .TIEsaBomber:
			return ["tiesa bomber", "tie bomber"]
		case .TIEcsPunisher:
			return ["tiecs punisher", "tie punisher"]
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
			return ["tieph phantom", "tie phantom"]
		case .VT49Decimator:
			return ["vt49 decimator", "decimator"]
		case .TIEagAggressor:
			return ["tieag aggressor", "tie aggressor"]
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
			return ["tie interceptor"]
		case .lancerPursuitCraft:
			return ["lancer pursuit craft"]
		case .TIEReaper:
			return ["tie reaper"]
		case .M3AInterceptor:
			return ["m3a interceptor"]
		case .jumpMaster5000:
			return ["jump master 5000"]
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
			return ["tievn silencer", "tie silencer"]
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
		}
	}
	
}
