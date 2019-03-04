//
//  CardsCollectionViewController.swift
//  X-Squad
//
//  Created by Avario on 11/01/2019.
//  Copyright © 2019 Avario. All rights reserved.
//
// This is an abstract screen that is used to show cards in a vertically scrolling list.

import Foundation
import UIKit

class CardsCollectionViewController: UICollectionViewController, CardViewDelegate, CardDetailsCollectionViewControllerDataSource, CardDetailsCollectionViewControllerDelegate {
	
	// This represents a section of cards. A section can have a header and then a number of cards.
	struct CardSection {
		
		let header: Header
		let cards: [Card]
		
		enum Header {
			case none
			case header(HeaderInfo)
		}
		
		struct HeaderInfo {
			let title: String
			let icon: String
			let iconFont: UIFont
		}
	}
	
	// This is the primary data source for the collection.
	var cardSections: [CardSection] = []
	
	init(columnLayout: CardCollectionViewLayout.ColumnLayout) {
		let layout = CardCollectionViewLayout(columnLayout: columnLayout)
		super.init(collectionViewLayout: layout)
		
		layout.delegate = self
	}
	
	required init?(coder aDecoder: NSCoder) {
		fatalError()
	}
	
	override var preferredStatusBarStyle: UIStatusBarStyle {
		return .lightContent
	}
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		view.backgroundColor = .black
		
		collectionView.register(CardCollectionViewCell.self, forCellWithReuseIdentifier: CardCollectionViewCell.identifier)
		collectionView.register(CardsSectionHeaderView.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: CardsSectionHeaderView.reuseIdentifier)
		
		collectionView.keyboardDismissMode = .onDrag
		collectionView.alwaysBounceVertical = true
		collectionView.contentInset = UIEdgeInsets(top: 10, left: 10, bottom: 20, right: 10)
		collectionView.backgroundColor = .clear
	}
	
	override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
		super.viewWillTransition(to: size, with: coordinator)
		collectionView.collectionViewLayout.invalidateLayout()
	}
	
	override func numberOfSections(in collectionView: UICollectionView) -> Int {
		return cardSections.count
	}
	
	override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
		return cardSections[section].cards.count
	}
	
	override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
		let cardCell = collectionView.dequeueReusableCell(withReuseIdentifier: CardCollectionViewCell.identifier, for: indexPath) as! CardCollectionViewCell
		cardCell.cardView.delegate = self
		
		let card = cardSections[indexPath.section].cards[indexPath.row]
		cardCell.card = card
		cardCell.status = status(for: card)
		
		return cardCell
	}
	
	override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
		let card = cardSections[indexPath.section].cards[indexPath.row]
		
		let cardDetailsCollectionViewController = CardDetailsCollectionViewController(initialCard: card)
		cardDetailsCollectionViewController.dataSource = self
		cardDetailsCollectionViewController.delegate = self
		
		if let topViewController = self.presentingViewController?.navigationController?.tabBarController {
			topViewController.present(cardDetailsCollectionViewController, animated: true, completion: nil)
		} else {
			self.present(cardDetailsCollectionViewController, animated: true, completion: nil)
		}
		
		// Scrol the collection view to make the selected card fully visible.
		let cellFrame = collectionView.layoutAttributesForItem(at: indexPath)!.frame
		collectionView.scrollRectToVisible(cellFrame, animated: true)
	}
	
	override func collectionView(_ collectionView: UICollectionView, didEndDisplaying cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
		if let cardCell = cell as? CardCollectionViewCell {
			// This is set to ensure the custom card transition only transitions cards that are actually visible.
			cardCell.cardView.isVisible = false
		}
	}
	
	override func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
		if let cardCell = cell as? CardCollectionViewCell {
			cardCell.cardView.isVisible = true
		}
	}
	
	override func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
		let sectionHeader = collectionView.dequeueReusableSupplementaryView(ofKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: CardsSectionHeaderView.reuseIdentifier, for: indexPath) as! CardsSectionHeaderView
		
		let cardSection = cardSections[indexPath.section]
		switch cardSection.header {
		case .none:
			break
		case .header(let headerInfo):
			sectionHeader.nameLabel.text = headerInfo.title
			sectionHeader.iconLabel.text = headerInfo.icon
			sectionHeader.iconLabel.font = headerInfo.iconFont
			sectionHeader.closeButton.isHidden = indexPath.section != 0
			sectionHeader.closeButton.addTarget(self, action: #selector(close), for: .touchUpInside)
		}
		
		return sectionHeader
	}
	
	@objc func close() {
		self.dismiss(animated: true, completion: nil)
	}
	
	open func status(for card: Card) -> CardCollectionViewCell.Status {
		// Used by subclasses.
		return .default
	}
	
	open func cardViewDidForcePress(_ cardView: CardView, touches: Set<UITouch>, with event: UIEvent?) {
		// Used by subclasses.
	}
	
	var cards: [Card] {
		return cardSections.reduce([Card](), { cards, cardSection in
			var cards = cards
			cards.append(contentsOf: cardSection.cards)
			return cards
		})
	}
	
	func member(for card: Card) -> Squad.Member? {
		return nil
	}
	
	func squadAction(for card: Card) -> SquadButton.Action? {
		return nil
	}
	
	func cost(for card: Card) -> Int {
		return card.pointCost()
	}
	
	func cardDetailsCollectionViewController(_ cardDetailsCollectionViewController: CardDetailsCollectionViewController, didPressSquadButtonFor card: Card) {
		
	}
	
	func cardDetailsCollectionViewController(_ cardDetailsCollectionViewController: CardDetailsCollectionViewController, didChangeFocusFrom fromCard: Card, to toCard: Card) {
		let fromCardIndex = indexPath(for: fromCard)!
		if let fromCardCell = collectionView.cellForItem(at: fromCardIndex) as? CardCollectionViewCell {
			fromCardCell.cardView.isHidden = false
		}
		
		let toCardIndex = indexPath(for: toCard)!
		let cellFrame = collectionView.layoutAttributesForItem(at: toCardIndex)!.frame
		collectionView.scrollRectToVisible(cellFrame, animated: false)
		
		if let toCardCell = collectionView.cellForItem(at: toCardIndex) as? CardCollectionViewCell {
			toCardCell.cardView.isHidden = true
		}
	}
	
	func indexPath(for card: Card) -> IndexPath? {
		for (sectionIndex, section) in cardSections.enumerated() {
			if let cardIndex = section.cards.firstIndex(where: { $0.matches(card) }) {
				return IndexPath(item: cardIndex, section: sectionIndex)
			}
		}
		return nil
	}
}

extension CardsCollectionViewController: CardCollectionViewLayoutDelegate {
	
	func collectionView(_ collectionView: UICollectionView, orientationForCardAtIndexPath indexPath: IndexPath) -> CardOrientation {
		let card = cardSections[indexPath.section].cards[indexPath.row]
		return card.orientation
	}
	
	func collectionView(_ collectionView: UICollectionView, shouldShowHeaderFor section: Int) -> Bool {
		let cardSection = cardSections[section]
		if case .none = cardSection.header {
			return false
		} else {
			return true
		}
	}
	
}
