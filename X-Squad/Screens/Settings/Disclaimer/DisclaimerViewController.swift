//
//  DisclaimerViewController.swift
//  X-Squad
//
//  Created by Avario on 08/01/2019.
//  Copyright © 2019 Avario. All rights reserved.
//
// This screen displays the FFG disclaimer.

import Foundation
import UIKit

class DisclaimerViewController: UITableViewController {
	
	init() {
		super.init(style: .grouped)
		title = "Disclaimer"
	}
	
	required init?(coder aDecoder: NSCoder) {
		fatalError()
	}
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		view.backgroundColor = UIColor(named: "XBackground")
		
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
		settingCell.textLabel?.text = "Fantasy Flight Games"
		
		return settingCell
	}
	
	override func tableView(_ tableView: UITableView, titleForFooterInSection section: Int) -> String? {
		return """
		X-Wing: The Miniatures Game is a trademark of Fantasy Flight Games.
		
		The X-Squad app is in no way affiliated with or endorsed by Fantasy Flight Games or any of its subsidiaries, employees, or associates. The creator of this app offers no suggestion that the content presented here is "official" or produced or sanctioned by the owner or any licensees of X-Wing: The Miniatures Game or Star Wars trademarks. Images displayed in this app are copyrighted to Fantasy Flight Games, or to the creator of the image.
		"""
	}
	
	override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		let url: URL = URL(string: "https://www.fantasyflightgames.com")!
		UIApplication.shared.open(url)
	}
	
}
