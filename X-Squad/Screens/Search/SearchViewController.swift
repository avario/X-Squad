//
//  SearchViewController.swift
//  X-Squad
//
//  Created by Avario on 09/02/2019.
//  Copyright © 2019 Avario. All rights reserved.
//

import Foundation
import UIKit

class SearchViewController: UITableViewController {
	
	override var preferredStatusBarStyle: UIStatusBarStyle {
		return .lightContent
	}
	
	init() {
		super.init(nibName: nil, bundle: nil)
		title = "Search"
		tabBarItem = UITabBarItem(title: "Search", image: UIImage(named: "Search Tab"), selectedImage: nil)
	}
	
	required init?(coder aDecoder: NSCoder) {
		fatalError()
	}
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		navigationController?.navigationBar.barStyle = .black
		navigationController?.navigationBar.prefersLargeTitles = true
		view.backgroundColor = .black
		
		let searchResultsViewController = SearchResultsViewController()
		let searchController = UISearchController(searchResultsController: searchResultsViewController)
		
		definesPresentationContext = true
		navigationItem.searchController = searchController
		navigationItem.hidesSearchBarWhenScrolling = false
		
		searchController.searchResultsUpdater = searchResultsViewController
		searchController.searchBar.autocapitalizationType = .words
		searchController.dimsBackgroundDuringPresentation = true
		searchController.obscuresBackgroundDuringPresentation = true
		searchController.searchBar.placeholder = "Search All Cards"
		
		let instructionsLabel = UILabel()
		instructionsLabel.textAlignment = .center
		instructionsLabel.textColor = UIColor.white.withAlphaComponent(0.3)
		instructionsLabel.text = "Search for things like:"
		
		let suggestionsStackView = UIStackView(arrangedSubviews: [instructionsLabel])
		suggestionsStackView.axis = .vertical
		suggestionsStackView.spacing = 10
		
		suggestionsStackView.translatesAutoresizingMaskIntoConstraints = false
		suggestionsStackView.widthAnchor.constraint(equalToConstant: view.frame.width).isActive = true
		suggestionsStackView.heightAnchor.constraint(equalToConstant: 140).isActive = true
		suggestionsStackView.isLayoutMarginsRelativeArrangement = true
		suggestionsStackView.layoutMargins = UIEdgeInsets(top: 20, left: 0, bottom: 0, right: 0)
		
		let suggestions = ["Han Solo", "TIE Interceptor", "Modification"]
		for suggestion in suggestions {
			let suggestionLabel = UILabel()
			suggestionLabel.textAlignment = .center
			suggestionLabel.textColor = UIColor.white.withAlphaComponent(0.5)
			suggestionLabel.font = UIFont.italicSystemFont(ofSize: 16)
			suggestionLabel.text = suggestion
			
			suggestionsStackView.addArrangedSubview(suggestionLabel)
		}
		
		tableView.tableHeaderView = suggestionsStackView
		tableView.separatorStyle = .none
	}
	
}
