//
//  CardStore.swift
//  X-Squad
//
//  Created by Avario on 03/01/2019.
//  Copyright © 2019 Avario. All rights reserved.
//

import Foundation

class CardStore {
	
	private init() { }
	
	public static var cards: [Card] {
		get { return savedCards }
		set { save(cards: newValue) }
	}
	
	public static var searchIndices: [SearchIndex] = createSearchIndices(for: cards)
	
	private static var savedCards: [Card] = loadCards()
	
	private static var fileURL: URL {
		let fileManager = FileManager.default
		let documentDirectory = try! fileManager.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false)
		return documentDirectory.appendingPathComponent("Xwing_Cards")
	}
	
	private static func save(cards: [Card]) {
		let fileData = try! JSONEncoder().encode(cards)
		try! fileData.write(to: fileURL)
		savedCards = cards
		searchIndices = createSearchIndices(for: cards)
	}
	
	private static func loadCards() -> [Card] {
		guard let fileData = try? Data(contentsOf: fileURL),
			let cards = try? JSONDecoder().decode([Card].self, from: fileData) else {
				return []
		}
		
		return cards
	}
	
	public static func card(forID id: Int) -> Card? {
		return cards.first(where: { $0.id == id })
	}
	
	public enum UpdateError: Swift.Error {
		case networkingError
		case noData
		case invalidData
	}
	
	public static var needsUpdate: Bool {
		return savedCards.isEmpty
	}
	
	public static func update(response: @escaping Response<[Card]>) {
		let session = URLSession(configuration: .default)
		let url = URL(string: "https://squadbuilder.fantasyflightgames.com/api/cards/")!
		let task = session.dataTask(with: url) { data, _, error in
			guard error == nil else {
				DispatchQueue.main.async {
					response(.failure(UpdateError.networkingError))
				}
				return
			}
			
			guard let data = data else {
				DispatchQueue.main.async {
					response(.failure(UpdateError.noData))
				}
				return
			}
			
			do {
				struct DownloadResponse: Codable {
					let cards: [Card]
				}
				
				let downloadResponse = try JSONDecoder().decode(DownloadResponse.self, from: data)
				let cards = downloadResponse.cards
				save(cards: cards)
				
				DispatchQueue.main.async {
					response(.success(cards))
				}
			} catch {
				DispatchQueue.main.async {
					response(.failure(UpdateError.invalidData))
				}
			}
		}
		
		task.resume()
	}
	
}
