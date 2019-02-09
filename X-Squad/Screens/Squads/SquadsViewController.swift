//
//  SquadsViewController.swift
//  X-Squad
//
//  Created by Avario on 08/02/2019.
//  Copyright © 2019 Avario. All rights reserved.
//

import Foundation
import UIKit

class SquadsViewController: UITableViewController {
	
	override var preferredStatusBarStyle: UIStatusBarStyle {
		return .lightContent
	}
	
	init() {
		super.init(style: .plain)
		title = "Squads"
		tabBarItem = UITabBarItem(title: "Squads", image: UIImage(named: "Squads Tab"), selectedImage: nil)
	}
	
	required init?(coder aDecoder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		navigationController?.navigationBar.barStyle = .black
		navigationController?.navigationBar.isTranslucent = false
		navigationController?.navigationBar.prefersLargeTitles = false
		view.backgroundColor = UIColor(named: "XBackground")
		
		definesPresentationContext = true
		
//		let addSquadButton = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addSquad))
//		navigationItem.rightBarButtonItem = addSquadButton
//		addSquadButton.tintColor = UIColor.white.withAlphaComponent(0.5)

		let addSquadButton = UIButton(type: .contactAdd)
		addSquadButton.addTarget(self, action: #selector(addSquad), for: .touchUpInside)
		addSquadButton.tintColor = UIColor.white.withAlphaComponent(0.5)
		
		let headerView = UIView(frame: CGRect(x: 0, y: 0, width: view.frame.width, height: 64))
		headerView.addSubview(addSquadButton)
		
		addSquadButton.translatesAutoresizingMaskIntoConstraints = false
		
		addSquadButton.widthAnchor.constraint(equalToConstant: 44).isActive = true
		addSquadButton.topAnchor.constraint(equalTo: headerView.topAnchor).isActive = true
		addSquadButton.rightAnchor.constraint(equalTo: headerView.rightAnchor).isActive = true
		addSquadButton.heightAnchor.constraint(equalToConstant: 44).isActive = true
		
		tableView.tableHeaderView = headerView
		
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
		
		let indexPath = IndexPath(row: squadIndex, section: 0)
		tableView.insertRows(at: [indexPath], with: .none)
		//		tableView.scrollToRow(at: indexPath, at: .bottom, animated: false)
		
		tableView.selectRow(at: indexPath, animated: false, scrollPosition: .bottom)
		tableView.deselectRow(at: indexPath, animated: true)
		
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
	
	@objc func addSquad() {
		present(UINavigationController(rootViewController: NewSquadViewController()), animated: true, completion: nil)
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
		tabBarController!.present(squadViewController, animated: true, completion: nil)
		
		tableView.deselectRow(at: indexPath, animated: true)
	}
	
}
