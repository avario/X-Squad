//
//  HomeViewController.swift
//  X-Squad
//
//  Created by Avario on 02/01/2019.
//  Copyright © 2019 Avario. All rights reserved.
//

import UIKit

class _HomeViewController: UITableViewController {
	
	override var preferredStatusBarStyle: UIStatusBarStyle {
		return .lightContent
	}
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		let xImage = UIImageView(image: UIImage(named: "X-Squad_X"))
		xImage.contentMode = .scaleAspectFit
		navigationItem.titleView = xImage
		navigationItem.largeTitleDisplayMode = .never
		
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
		
		let settingsButton = UIBarButtonItem(image: UIImage(named: "Settings"), style: .done, target: self, action: #selector(showSettings))
		navigationItem.leftBarButtonItem = settingsButton
		
		let addSquadButton = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addSquad))
		navigationItem.rightBarButtonItem = addSquadButton
		
		tableView.separatorColor = UIColor.white.withAlphaComponent(0.2)
		tableView.rowHeight = SquadCell.rowHeight
		tableView.tableFooterView = UIView()
		
		tableView.register(SquadCell.self, forCellReuseIdentifier: SquadCell.reuseIdentifier)
		
		updateEmptyView()
		
		NotificationCenter.default.addObserver(self, selector: #selector(squadAdded), name: .squadStoreDidAddSquad, object: nil)
		NotificationCenter.default.addObserver(self, selector: #selector(squadDeleted), name: .squadStoreDidDeleteSquad, object: nil)
	}
	
	var squads = SquadStore.squads
	
	@objc func squadAdded(notification: Notification) {
		guard let squad = notification.object as? Squad,
			let squadIndex = SquadStore.squads.firstIndex(of: squad) else {
			return
		}
		
		squads = SquadStore.squads
		tableView.insertRows(at: [IndexPath(row: squadIndex, section: 0)], with: .none)
		
		updateEmptyView()
	}
	
	@objc func squadDeleted(notification: Notification) {
		guard let squad = notification.object as? Squad,
			let squadIndex = squads.firstIndex(of: squad) else {
				return
		}
		
		squads = SquadStore.squads
		tableView.deleteRows(at: [IndexPath(row: squadIndex, section: 0)], with: .none)
		
		updateEmptyView()
	}
	
	func updateEmptyView() {
		tableView.backgroundView = squads.isEmpty ? SquadsEmptyView() : nil
	}
	
	@objc func showSettings() {
		let navigationController = UINavigationController(navigationBarClass: DarkNavigationBar.self, toolbarClass: nil)
		navigationController.viewControllers = [SettingsViewController()]
		present(navigationController, animated: true, completion: nil)
	}
	
	@objc func addSquad() {
		let navigationController = UINavigationController(navigationBarClass: DarkNavigationBar.self, toolbarClass: nil)
		navigationController.viewControllers = [NewSquadViewController()]
		present(navigationController, animated: true, completion: nil)
	}
	
	override func numberOfSections(in tableView: UITableView) -> Int {
		return 1
	}
	
	override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return squads.count
	}
	
	override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let squadCell = tableView.dequeueReusableCell(withIdentifier: SquadCell.reuseIdentifier) as! SquadCell
		squadCell.squad = squads[indexPath.row]
		
		return squadCell
	}
	
	override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		let squad = squads[indexPath.row]
		let squadViewController = SquadViewController(for: squad)
		navigationController!.present(squadViewController, animated: true, completion: nil)
		
		tableView.deselectRow(at: indexPath, animated: true)
	}
	
}
