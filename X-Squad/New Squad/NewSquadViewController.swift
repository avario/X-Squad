//
//  NewSquadViewController.swift
//  X-Squad
//
//  Created by Avario on 10/01/2019.
//  Copyright © 2019 Avario. All rights reserved.
//

import Foundation
import UIKit

class NewSquadViewController: UITableViewController {
	
	init() {
		super.init(style: .grouped)
		title = "New Squad"
		
		let cancelButton = UIBarButtonItem(title: "Cancel", style: .plain, target: self, action: #selector(cancel))
		navigationItem.rightBarButtonItem = cancelButton
	}
	
	required init?(coder aDecoder: NSCoder) {
		fatalError()
	}
	
	@objc func cancel() {
		dismiss(animated: true, completion: nil)
	}
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		view.backgroundColor = .black
		
		tableView.register(FactionCell.self, forCellReuseIdentifier: FactionCell.reuseIdentifier)
		tableView.separatorColor = UIColor.white.withAlphaComponent(0.2)
		tableView.rowHeight = 50
	}
	
	override func numberOfSections(in tableView: UITableView) -> Int {
		return 1
	}
	
	override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return Card.Faction.allCases.count
	}
	
	override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let factionCell = tableView.dequeueReusableCell(withIdentifier: FactionCell.reuseIdentifier) as! FactionCell
		factionCell.faction = Card.Faction.allCases[indexPath.row]
		return factionCell
	}
	
	override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
		return "Select a faction:"
	}
	
	override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		let faction = Card.Faction.allCases[indexPath.row]
		let squad = Squad(faction: faction)
		SquadStore.add(squad: squad)
		
		dismiss(animated: true, completion: nil)
	}
	
}
