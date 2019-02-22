//
//  NewGameViewController.swift
//  X-Squad
//
//  Created by Avario on 13/02/2019.
//  Copyright © 2019 Avario. All rights reserved.
//
// This screen allows the user to start a new game.

import Foundation
import UIKit

class NewGameViewController: UITableViewController {
	
	init() {
		super.init(style: .grouped)
		title = "New Game"
		tabBarItem = UITabBarItem(title: "Game", image: UIImage(named: "Game Tab"), selectedImage: nil)
	}
	
	required init?(coder aDecoder: NSCoder) {
		fatalError()
	}
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		view.backgroundColor = .black
		navigationController?.navigationBar.barStyle = .black
		navigationController?.navigationBar.isTranslucent = true
		navigationController?.navigationBar.prefersLargeTitles = true
		
		tableView.register(SettingCell.self, forCellReuseIdentifier: SettingCell.reuseIdentifier)
		tableView.separatorColor = UIColor.white.withAlphaComponent(0.2)
	}
	
	override func numberOfSections(in tableView: UITableView) -> Int {
		return 1
	}
	
	override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return 1
	}
	
	override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let settingCell = tableView.dequeueReusableCell(withIdentifier: SettingCell.reuseIdentifier) as! SettingCell
		settingCell.accessoryType = .disclosureIndicator
		settingCell.textLabel?.text = "Start a New Game"
		
		return settingCell
	}
	
	override func tableView(_ tableView: UITableView, titleForFooterInSection section: Int) -> String? {
		return "Manage all of your cards and tokens in the app."
	}
	
	override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		let selectSquadViewController = SelectSquadViewController()
		navigationController?.pushViewController(selectSquadViewController, animated: true)
	}
	
}
