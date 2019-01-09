//
//  SearchResultsViewController.swift
//  X-Squad
//
//  Created by Avario on 03/01/2019.
//  Copyright © 2019 Avario. All rights reserved.
//

import UIKit

class SearchResultsViewController: UICollectionViewController {
	
	var searchResults: [Card] = []
	
	init() {
		let layout = CardCollectionViewLayout()
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
		collectionView.keyboardDismissMode = .onDrag
		collectionView.alwaysBounceVertical = true
		collectionView.contentInset = UIEdgeInsets(top: 10, left: 10, bottom: 30, right: 10)
	}
	
	override func viewDidAppear(_ animated: Bool) {
		super.viewDidAppear(animated)
		navigationItem.hidesSearchBarWhenScrolling = true
	}
	
	override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
		return searchResults.count
	}
	
	override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
		let cardCell = collectionView.dequeueReusableCell(withReuseIdentifier: CardCollectionViewCell.identifier, for: indexPath) as! CardCollectionViewCell
		cardCell.card = searchResults[indexPath.item]
		
		return cardCell
	}
	
	override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
		let card = searchResults[indexPath.item]
		let cardViewController = CardViewController(card: card)
		cardViewController.modalPresentationStyle = .overCurrentContext
		self.presentingViewController?.navigationController?.present(cardViewController, animated: true, completion: nil)
		
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
	
}

extension SearchResultsViewController: CardCollectionViewLayoutDelegate {
	
	func collectionView(_ collectionView: UICollectionView, orientationForCardAtIndexPath indexPath: IndexPath) -> CardCollectionViewLayout.CardOrientation {
		
		let card = searchResults[indexPath.item]
		
		switch card.type {
		case .pilot:
			return .portrait
		case .upgrade:
			return .landscape
		}
	}
	
}

extension SearchResultsViewController: UISearchResultsUpdating {
	func updateSearchResults(for searchController: UISearchController) {
		guard searchController.searchBar.text?.isEmpty == false else {
			searchResults = []
			collectionView.reloadData()
			return
		}
		
		searchResults = CardStore.searchResults(for: searchController.searchBar.text!)
		collectionView.reloadData()
	}
}
