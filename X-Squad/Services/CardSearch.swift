//
//  CardSearch.swift
//  X-Squad
//
//  Created by Avario on 23/01/2019.
//  Copyright © 2019 Avario. All rights reserved.
//
// Handles searching cards on the Search screen.

import Foundation

class CardSearch {
	
	static let shared = CardSearch()
	
	// An index is created for each card to improve search performance.
	private var searchIndices: [SearchIndex]
	
	private init() {
		searchIndices = CardSearch.createSearchIndices()
	}
	
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
	
	func updateSearchIndices() {
		searchIndices = CardSearch.createSearchIndices()
	}
	
	func searchResults(for term: String) -> [Card] {
		let validSearchTerm = term
			.trimmingCharacters(in: CharacterSet.whitespaces)
			.components(separatedBy: SearchIndex.invalidSearchCharacters)
			.joined()
			.lowercased()
		
		guard validSearchTerm.isEmpty == false else {
			return []
		}
		
		var results: [Card] = []
		
		// All of the terms associated with the card and checked to see if any of them begin with the target search term.
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
			var shipTerms = SearchIndex.terms(for: ship.name)
			
			if ship.name.hasPrefix("TIE/"),
				let slashIndex = ship.name.firstIndex(of: "/"),
				let spaceIndex = ship.name.firstIndex(of: " ") {
				let tieName = String(ship.name.prefix(upTo: slashIndex) + ship.name.suffix(from: spaceIndex)).lowercased()
				shipTerms.append(tieName)
			}
			
			self.init(card: pilot, additionalTerms: shipTerms)
		}
		
		init(upgrade: Upgrade) {
			let upgradeTerms = upgrade.sides.map { $0.slots.map { $0.rawValue.lowercased() } }.flatMap({ $0 })
			self.init(card: upgrade, additionalTerms: upgradeTerms)
		}
		
		private init(card: Card, additionalTerms: [String]) {
			self.card = card
			
			self.titleTerms = SearchIndex.terms(for: card.name)
			self.additionalTerms = additionalTerms
		}
		
		static func terms(for phrase: String) -> [String] {
			let cleanedPhrase = phrase
				.components(separatedBy: SearchIndex.invalidSearchCharacters)
				.joined()
				.lowercased()
			
			var terms = [cleanedPhrase]
			
			// A phrase like "Heavy Laser Cannon" will be split up into terms "Heavy Laser Cannon", "Laser Cannon", and "Cannon" so it will match match search terms "Heavy Laser Cannon", "Heavy Laser", "Laser Cannon", "Heavy", "Laser", and "Cannon".
			var components = cleanedPhrase.components(separatedBy: CharacterSet.whitespaces)
			while components.count > 1 {
				components.removeFirst()
				terms.append(components.joined(separator: " "))
			}
			
			return terms
		}
	}
	
}
