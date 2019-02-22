//
//  CardDetailsViewController.swift
//  X-Squad
//
//  Created by Avario on 21/02/2019.
//  Copyright © 2019 Avario. All rights reserved.
//

import Foundation
import UIKit

protocol CardDetailsCollectionViewControllerDataSource: AnyObject {
	var cards: [Card] { get }
	func member(for card: Card) -> Squad.Member?
	func squadAction(for card: Card) -> SquadButton.Action?
	func cost(for card: Card) -> Int
}

protocol CardDetailsCollectionViewControllerDelegate: AnyObject {
	func cardDetailsCollectionViewController(_ cardDetailsCollectionViewController: CardDetailsCollectionViewController, didPressSquadButtonFor card: Card)
	func cardDetailsCollectionViewController(_ cardDetailsCollectionViewController: CardDetailsCollectionViewController, didChangeFocusFrom fromCard: Card, to toCard: Card)
}

class CardDetailsCollectionViewController: UICollectionViewController, CardDetailsCollectionViewCellDelegate {
	
	weak var dataSource: CardDetailsCollectionViewControllerDataSource!
	weak var delegate: CardDetailsCollectionViewControllerDelegate?
	let layout: UICollectionViewFlowLayout
	
	private var focussedCard: Card
	
	var currentCell: CardDetailsCollectionViewCell?
	
	init(initialCard: Card) {
		self.focussedCard = initialCard
		
		layout = UICollectionViewFlowLayout()
		layout.scrollDirection = .horizontal
		layout.sectionInset = .zero
		layout.minimumInteritemSpacing = 0
		layout.minimumLineSpacing = 0
		
		super.init(collectionViewLayout: layout)
		
		transitioningDelegate = self
		modalPresentationStyle = .overCurrentContext
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
		collectionView.backgroundColor = .clear
		layout.itemSize = view.bounds.size
		
		collectionView.register(CardDetailsCollectionViewCell.self, forCellWithReuseIdentifier: CardDetailsCollectionViewCell.reuseIdentifier)
		collectionView.isPagingEnabled = true
		
		if let index = dataSource.cards.firstIndex(where: { $0.matches(focussedCard) }) {
			collectionView.scrollToItem(at: IndexPath(item: index, section: 0), at: .right, animated: false)
		}
		
		// Close button
		let closeButton = SmallButton()
		closeButton.translatesAutoresizingMaskIntoConstraints = false
		closeButton.setTitle("Close", for: .normal)
		
		view.addSubview(closeButton)
		closeButton.rightAnchor.constraint(equalTo: view.safeAreaLayoutGuide.rightAnchor, constant: -20).isActive = true
		closeButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor).isActive = true
		
		closeButton.addTarget(self, action: #selector(close), for: .touchUpInside)
	}
	
	func didPressSquadButton(for cardDetailsCollectionViewCell: CardDetailsCollectionViewCell) {
		delegate?.cardDetailsCollectionViewController(self, didPressSquadButtonFor: cardDetailsCollectionViewCell.card!)
	}
	
	@objc func close() {
		dismiss(animated: true, completion: nil)
	}
	
	override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
		return dataSource.cards.count
	}
	
	override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
		let cardCell = collectionView.dequeueReusableCell(withReuseIdentifier: CardDetailsCollectionViewCell.reuseIdentifier, for: indexPath) as! CardDetailsCollectionViewCell
		
		let card = dataSource.cards[indexPath.item]
		cardCell.card = card
		
		let member = dataSource.member(for: card)
		cardCell.member = member
		
		cardCell.cost = dataSource.cost(for: card)
		cardCell.squadAction = dataSource.squadAction(for: card)
		cardCell.pullToDismissController.viewController = self
		cardCell.delegate = self
		
		if currentCell == nil {
			currentCell = cardCell
		}
		
		return cardCell
	}
	
	override func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
		let index = Int(collectionView.contentOffset.x / layout.itemSize.width)
		let card = dataSource.cards[index]
		
		delegate?.cardDetailsCollectionViewController(self, didChangeFocusFrom: focussedCard, to: card)
		focussedCard = card
		
		for cell in collectionView.visibleCells {
			let cardCell = cell as! CardDetailsCollectionViewCell
			cardCell.underView.isHidden = false
			
			if cardCell.card?.matches(card) ?? false {
				currentCell = cardCell
			}
		}
	}
	
	override func scrollViewDidScroll(_ scrollView: UIScrollView) {
		let centerX = collectionView.contentOffset.x + collectionView.bounds.width/2
		
		for cell in collectionView.visibleCells {
			let cardCell = cell as! CardDetailsCollectionViewCell
			let offsetFromCenterX = cardCell.center.x - centerX
			cardCell.cardView.center.x = cardCell.bounds.midX + (offsetFromCenterX * 0.1)
			
			cardCell.underView.isHidden = true
		}
	}
	
	override func collectionView(_ collectionView: UICollectionView, didEndDisplaying cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
		if let cardCell = cell as? CardDetailsCollectionViewCell {
			// This is set to ensure the custom card transition only transitions cards that are actually visible.
			cardCell.cardView.isVisible = false
		}
	}
	
	override func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
		if let cardCell = cell as? CardDetailsCollectionViewCell {
			cardCell.cardView.isHidden = false
			cardCell.cardView.isVisible = true
		}
	}
	
	var dismissTargetViewController: UIViewController?
}

extension CardDetailsCollectionViewController: UIViewControllerTransitioningDelegate {
	
	func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
		return CardsPresentAnimationController()
	}
	
	func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
		return CardsDismissAnimationController(targetViewController: dismissTargetViewController)
	}
	
}
