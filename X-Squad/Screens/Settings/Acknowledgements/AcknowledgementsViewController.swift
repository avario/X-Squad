//
//  AcknowledgementsViewController.swift
//  X-Squad
//
//  Created by Avario on 08/01/2019.
//  Copyright © 2019 Avario. All rights reserved.
//
// This screen displays acknowledgements for tools used by the app.

import Foundation
import UIKit

class AcknowledgementsViewController: UITableViewController {
	
	enum Section: Int, CaseIterable {
		case data
		case font
		case xws
		case imageCache
	}
	
	init() {
		super.init(style: .grouped)
		title = "Acknowledgements"
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
		return Section.allCases.count
	}
	
	override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return 1
	}
	
	override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let settingCell = tableView.dequeueReusableCell(withIdentifier: SettingCell.reuseIdentifier) as! SettingCell
		settingCell.accessoryType = .disclosureIndicator
		
		switch Section(rawValue: indexPath.section)! {
		case .data:
			settingCell.textLabel?.text = "X-Wing Data 2"
		case .font:
			settingCell.textLabel?.text = "X-Wing Miniatures Font"
		case .xws:
			settingCell.textLabel?.text = "XWS Spec 2.0.0"
		case .imageCache:
			settingCell.textLabel?.text = "Kingfisher"
		}
		
		return settingCell
	}
	
	override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
		switch Section(rawValue: section)! {
		case .data:
			return "Card Data"
		case .font:
			return "Icons"
		case .imageCache:
			return "Image Cache"
		case .xws:
			return "XWS"
		}
	}
	
	override func tableView(_ tableView: UITableView, titleForFooterInSection section: Int) -> String? {
		switch Section(rawValue: section)! {
		case .data:
			return "X-Squad uses card data compiled by Guido Kessels, Philip Douglas, and many other contributors."
		case .font:
			return "X-Squad uses the X-Wing Miniatures Font by Hinny, armoredgear7, ScottKarch, and FedoraMark."
		case .imageCache:
			return "X-Squad uses the Kingfisher library for image downloading and caching."
		case .xws:
			return "X-Squad uses the XWS spec by Eli Stevens to import and export squads in a consistent format."
		}
	}
	
	override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		let url: URL
		switch Section(rawValue: indexPath.section)! {
		case .data:
			url = URL(string: "https://github.com/guidokessels/xwing-data2")!
		case .font:
			url = URL(string: "https://github.com/geordanr/xwing-miniatures-font")!
		case .imageCache:
			url = URL(string: "https://github.com/onevcat/Kingfisher")!
		case .xws:
			url = URL(string: "https://github.com/elistevens/xws-spec")!
		}
		
		UIApplication.shared.open(url)
		tableView.deselectRow(at: indexPath, animated: true)
	}
	
}
