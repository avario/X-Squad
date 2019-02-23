//
//  SearchResultsViewController.swift
//  X-Squad
//
//  Created by Avario on 03/01/2019.
//  Copyright © 2019 Avario. All rights reserved.
//
// This screen displays cards for the results of a search.

import UIKit

class SearchResultsViewController: CardsCollectionViewController {
	
	init() {
		super.init(numberOfColumns: 2)
	}
	
	required init?(coder aDecoder: NSCoder) {
		fatalError()
	}
	
	var searchResults: [Card] = [] {
		didSet {
			cardSections = [CardSection(header: .none, cards: searchResults)]
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
		
		searchResults = CardSearch.searchResults(for: searchController.searchBar.text!)
		collectionView.reloadData()
	}
}
