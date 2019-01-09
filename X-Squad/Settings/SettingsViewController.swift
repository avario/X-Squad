//
//  SettingsViewController.swift
//  X-Squad
//
//  Created by Avario on 08/01/2019.
//  Copyright © 2019 Avario. All rights reserved.
//

import Foundation
import UIKit
import MessageUI

class SettingsViewController: UITableViewController, MFMailComposeViewControllerDelegate {
	
	enum Section: Int, CaseIterable {
		case updateCards
		case downloadImages
		case developer
	}
	
	enum DeveloperCell: Int, CaseIterable {
		case acknowledgements
		case disclaimer
		case feedback
	}
	
	init() {
		super.init(style: .grouped)
		title = "Settings"
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
		switch Section(rawValue: section)! {
		case .updateCards, .downloadImages:
			return 1
		case .developer:
			return DeveloperCell.allCases.count
		}
	}
	
	override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let settingCell = tableView.dequeueReusableCell(withIdentifier: SettingCell.reuseIdentifier) as! SettingCell
		settingCell.accessoryType = .none
		
		switch Section(rawValue: indexPath.section)! {
		case .updateCards:
			settingCell.textLabel?.text = "Update Card Database"
		case .downloadImages:
			settingCell.textLabel?.text = "Download All Card Images"
		case .developer:
			switch DeveloperCell(rawValue: indexPath.row)! {
			case .acknowledgements:
				settingCell.textLabel?.text = "Acknowledgements"
				settingCell.accessoryType = .disclosureIndicator
			case .disclaimer:
				settingCell.textLabel?.text = "Disclaimer"
				settingCell.accessoryType = .disclosureIndicator
			case .feedback:
				settingCell.textLabel?.text = "Send Feedback"
			}
		}
		
		return settingCell
	}
	
	override func tableView(_ tableView: UITableView, titleForFooterInSection section: Int) -> String? {
		switch Section(rawValue: section)! {
		case .updateCards:
			return "Update all cards to the latest data available from FFG."
		case .downloadImages:
			return "Download all card images so that they can be viewed offline. This may use up to 100MB of data."
		case .developer:
			let appVersion = Bundle.main.infoDictionary!["CFBundleShortVersionString"] as! String
			return "X-Squad Version \(appVersion)"
		}
	}
	
	override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		switch Section(rawValue: indexPath.section)! {
		case .updateCards:
			let updateCardsViewController = UpdateCardsViewController()
			navigationController?.pushViewController(updateCardsViewController, animated: true)
			updateCardsViewController.update(dismissOnCompletion: true)
		case .downloadImages:
			let navigationController = UINavigationController(navigationBarClass: DarkNavigationBar.self, toolbarClass: nil)
			navigationController.viewControllers = [DownloadViewController()]
			present(navigationController, animated: true, completion: nil)
		case .developer:
			switch DeveloperCell(rawValue: indexPath.row)! {
			case .acknowledgements:
				let acknowledgementsViewController = AcknowledgementsViewController()
				navigationController?.pushViewController(acknowledgementsViewController, animated: true)
			case .disclaimer:
				let disclaimerViewController = DisclaimerViewController()
				navigationController?.pushViewController(disclaimerViewController, animated: true)
			case .feedback:
				let composeVC = MFMailComposeViewController()
				composeVC.mailComposeDelegate = self
				
				composeVC.setToRecipients(["avario@hotmail.com"])
				composeVC.setSubject("X-Squad Feedback")
				
				self.present(composeVC, animated: true, completion: nil)
			}
		}
	}
	
	func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
		controller.dismiss(animated: true, completion: nil)
	}
	
}
