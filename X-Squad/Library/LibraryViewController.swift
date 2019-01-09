//
//  LibraryViewController.swift
//  X-Squad
//
//  Created by Avario on 02/01/2019.
//  Copyright © 2019 Avario. All rights reserved.
//

import UIKit

class LibraryViewController: UIViewController {
	
	override var preferredStatusBarStyle: UIStatusBarStyle {
		return .lightContent
	}
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		let xImage = UIImageView(image: UIImage(named: "X-Squad_X"))
		xImage.contentMode = .scaleAspectFit
		navigationItem.titleView = xImage
		
		navigationController?.navigationBar.barStyle = .black
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
		
		let settingsButton = UIBarButtonItem(image: UIImage(named: "settings_icon"), style: .done, target: self, action: #selector(showSettings))
		navigationItem.rightBarButtonItem = settingsButton
		
//		let instructionsLabel = UILabel()
//		instructionsLabel.textAlignment = .center
//		instructionsLabel.textColor = UIColor.white.withAlphaComponent(0.3)
//		instructionsLabel.numberOfLines = 0
//		instructionsLabel.translatesAutoresizingMaskIntoConstraints = false
//		instructionsLabel.font = UIFont.eurostile(18)
//		instructionsLabel.text = "Search by card title, ship type, or upgrade type.\n\ne.g. \"Han Solo\", \"X-wing\", \"Crew\""
//
//		view.addSubview(instructionsLabel)
//		instructionsLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 40).isActive = true
//		instructionsLabel.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 40).isActive = true
//		instructionsLabel.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -40).isActive = true
	}
	
	override func viewDidAppear(_ animated: Bool) {
		super.viewDidAppear(animated)
		navigationItem.hidesSearchBarWhenScrolling = true
	}
	
	@objc func showSettings() {
		let settingsViewController = SettingsViewController()
		navigationController?.pushViewController(settingsViewController, animated: true)
	}
	
}
