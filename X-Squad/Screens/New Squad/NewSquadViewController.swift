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
	
	enum Section: Int, CaseIterable {
		case factions
		case xws
	}
	
	enum XWSRow: Int, CaseIterable {
		case clipboard
		case qrCode
	}
	
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
		
		view.backgroundColor = UIColor(named: "XBackground")
		navigationController?.navigationBar.barStyle = .black
		navigationController?.navigationBar.prefersLargeTitles = true
		
		tableView.register(FactionCell.self, forCellReuseIdentifier: FactionCell.reuseIdentifier)
		tableView.register(SettingCell.self, forCellReuseIdentifier: SettingCell.reuseIdentifier)
		tableView.separatorColor = UIColor.white.withAlphaComponent(0.2)
		tableView.rowHeight = 50
	}
	
	override func numberOfSections(in tableView: UITableView) -> Int {
		return Section.allCases.count
	}
	
	override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		switch Section(rawValue: section)! {
		case .factions:
			return Faction.releasedFactions.count
		case .xws:
			return XWSRow.allCases.count
		}
		
	}
	
	override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		switch Section(rawValue: indexPath.section)! {
		case .factions:
			let factionCell = tableView.dequeueReusableCell(withIdentifier: FactionCell.reuseIdentifier) as! FactionCell
			factionCell.faction = Faction.releasedFactions[indexPath.row]
			return factionCell
		case .xws:
			let settingCell = tableView.dequeueReusableCell(withIdentifier: SettingCell.reuseIdentifier) as! SettingCell
			switch XWSRow(rawValue: indexPath.row)! {
			case .clipboard:
				settingCell.textLabel?.text = "Use XWS from Clipboard"
				settingCell.accessoryType = .none
			case .qrCode:
				settingCell.textLabel?.text = "Scan XWS QR Code"
				settingCell.accessoryType = .disclosureIndicator
			}
			return settingCell
		}
	}
	
	override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
		switch Section(rawValue: section)! {
		case .factions:
			return "Select a faction"
		case .xws:
			return "Import from XWS"
		}
		
	}
	
	override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		switch Section(rawValue: indexPath.section)! {
		case .factions:
			let faction = Faction.releasedFactions[indexPath.row]
			let squad = Squad(faction: faction)
			SquadStore.add(squad: squad)
			
			dismiss(animated: true, completion: nil)
		case .xws:
			switch XWSRow(rawValue: indexPath.row)! {
			case .clipboard:
				importXWS()
				tableView.deselectRow(at: indexPath, animated: true)
			case .qrCode:
				scanXWSQRCode()
			}
		}
	}
	
	func importXWS() {
		guard let xwsData = UIPasteboard.general.string?.data(using: .utf8) else {
			let alert = UIAlertController(title: "Empty Clipboard", message: "Your clipboard is empty. Copy the XWS text to your clipboard and try again.", preferredStyle: .alert)
			alert.addAction(UIAlertAction(title: "Okay", style: .default) { _ in })
			self.present(alert, animated: true, completion: nil)
			return
		}
		
		do {
			let xws = try JSONDecoder().decode(XWS.self, from: xwsData)
			let squad = Squad(xws: xws)
			SquadStore.add(squad: squad)
			
			let tabViewController = self.presentingViewController!
			dismiss(animated: true) {
				let squadViewController = EditSquadViewController(for: squad)
				tabViewController.present(squadViewController, animated: true, completion: nil)
			}
		} catch {
			let alert = UIAlertController(title: "Invalid XWS", message: "The data on your clipboard was not in a valid XWS format. Copy the XWS text to your clipboard and try again.", preferredStyle: .alert)
			alert.addAction(UIAlertAction(title: "Okay", style: .default) { _ in })
			self.present(alert, animated: true, completion: nil)
		}
		
	}
	
	func scanXWSQRCode() {
		navigationController?.pushViewController(ScanViewController(), animated: true)
	}
	
}
