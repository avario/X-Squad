//
//  AcknowledgementsViewController.swift
//  X-Squad
//
//  Created by Avario on 08/01/2019.
//  Copyright © 2019 Avario. All rights reserved.
//

import Foundation
import UIKit

class AcknowledgementsViewController: UITableViewController {
	
	enum Section: Int, CaseIterable {
		case font
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
		
		view.backgroundColor = .black
		
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
		case .font:
			settingCell.textLabel?.text = "X-Wing Miniatures Font"
		case .imageCache:
			settingCell.textLabel?.text = "Kingfisher"
		}
		
		return settingCell
	}
	
	override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
		switch Section(rawValue: section)! {
		case .font:
			return "Icons"
		case .imageCache:
			return "Image Cache"
		}
	}
	
	override func tableView(_ tableView: UITableView, titleForFooterInSection section: Int) -> String? {
		switch Section(rawValue: section)! {
		case .font:
			return "X-Squad uses the X-Wing Miniatures Font by Hinny, armoredgear7, ScottKarch, and FedoraMark for excellent vector icons."
		case .imageCache:
			return "X-Squad uses the Kingfisher library for image downloading and caching."
		}
	}
	
	override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		let url: URL
		switch Section(rawValue: indexPath.section)! {
		case .font:
			url = URL(string: "https://github.com/geordanr/xwing-miniatures-font")!
		case .imageCache:
			url = URL(string: "https://github.com/onevcat/Kingfisher")!
		}
		
		UIApplication.shared.open(url)
	}
	
}
