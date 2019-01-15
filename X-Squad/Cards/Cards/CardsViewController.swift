//
//  CardsViewController.swift
//  X-Squad
//
//  Created by Avario on 11/01/2019.
//  Copyright © 2019 Avario. All rights reserved.
//

import Foundation
import UIKit

class CardsViewController: UICollectionViewController, CardViewControllerDelegate {
	
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
	
	var cardSections: [CardSection] = []
	
	init(numberOfColumns: Int) {		
		let layout = CardCollectionViewLayout(numberOfColumns: numberOfColumns)
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
		collectionView.contentInset = UIEdgeInsets(top: 10, left: 10, bottom: 30, right: 10)
		collectionView.backgroundColor = .clear
	}
	
	override func numberOfSections(in collectionView: UICollectionView) -> Int {
		return cardSections.count
	}
	
	override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
		return cardSections[section].cards.count
	}
	
	override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
		let cardCell = collectionView.dequeueReusableCell(withReuseIdentifier: CardCollectionViewCell.identifier, for: indexPath) as! CardCollectionViewCell
		
		let card = cardSections[indexPath.section].cards[indexPath.row]
		cardCell.card = card
		cardCell.status = status(for: card, at: indexPath)
		
		return cardCell
	}
	
	override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
		let card = cardSections[indexPath.section].cards[indexPath.row]
		let cardViewController = CardViewController(card: card, id: id(for: card))
		cardViewController.delegate = self
		if let topViewController = self.presentingViewController?.navigationController {
			topViewController.present(cardViewController, animated: true, completion: nil)
		} else {
			self.present(cardViewController, animated: true, completion: nil)
		}
		
		let cellFrame = collectionView.layoutAttributesForItem(at: indexPath)!.frame
		collectionView.scrollRectToVisible(cellFrame, animated: true)
	}
	
	override func collectionView(_ collectionView: UICollectionView, didEndDisplaying cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
		if let cardCell = cell as? CardCollectionViewCell {
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
		}
		
		return sectionHeader
	}
	
	open func id(for card: Card) -> String {
		return card.defaultID
	}
	
	open func cardViewController(_ cardViewController: CardViewController, didSelect card: Card) {
		
	}
	
	open func status(for card: Card, at index: IndexPath) -> CardCollectionViewCell.Status {
		return .default
	}
	
}

extension CardsViewController: CardCollectionViewLayoutDelegate {
	
	func collectionView(_ collectionView: UICollectionView, orientationForCardAtIndexPath indexPath: IndexPath) -> CardCollectionViewLayout.CardOrientation {
		
		let card = cardSections[indexPath.section].cards[indexPath.row]
		
		switch card.type {
		case .pilot:
			return .portrait
		case .upgrade:
			return .landscape
		}
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
