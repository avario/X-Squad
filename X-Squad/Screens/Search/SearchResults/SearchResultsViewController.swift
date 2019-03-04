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
		let columnLayout: CardCollectionViewLayout.ColumnLayout
		switch UIDevice.current.userInterfaceIdiom {
		case .pad:
			columnLayout = .width(300)
		case .phone:
			columnLayout = .number(2)
		default:
			fatalError()
		}
		
		super.init(columnLayout: columnLayout)
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
