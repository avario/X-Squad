//
//  UpdateCardsViewController.swift
//  X-Squad
//
//  Created by Avario on 03/01/2019.
//  Copyright © 2019 Avario. All rights reserved.
//

import Foundation
import UIKit

class UpdateCardsViewController: DownloadViewController {
	
	init() {
		super.init(nibName: nil, bundle: nil)
		title = "Update Database"
	}
	
	required init?(coder aDecoder: NSCoder) {
		fatalError()
	}
	
	override func viewDidLoad() {
		super.viewDidLoad()
		label.text = "Updating Card Database"
		progressView.isHidden = true
	}
	
	func update(dismissOnCompletion: Bool) {
		activityIndicator.startAnimating()

		CardStore.update { (result) in
			if dismissOnCompletion {
				self.dismiss(animated: true, completion: nil)
			}

			switch result {
			case .success:
				if !dismissOnCompletion {
					self.showHome()
				}

			case .failure(let error as CardStore.UpdateError):
				switch error {
				case .networkingError:
					self.showUpdateError("Check your network connection and try again.", dismissOnCompletion: dismissOnCompletion)

				case .noData, .invalidData:
					self.showUpdateError("It looks like there's some trouble accessing the FFG card database. Make sure you're using the latest version of the app.", dismissOnCompletion: dismissOnCompletion)
				}
			case .failure:
				fatalError("Unexpected error from cards update.")
			}

			self.activityIndicator.stopAnimating()
		}
	}
	
	func showHome() {
		let window = UIApplication.shared.keyWindow!
		window.rootViewController = MainTabBarController()
	}
	
	func showUpdateError(_ updateError: String, dismissOnCompletion: Bool) {
		let alert = UIAlertController(title: "Failed to Load Cards", message: updateError, preferredStyle: .alert)
		if dismissOnCompletion == false {
			alert.addAction(UIAlertAction(title: "Retry", style: .default, handler: { _ in
				self.update(dismissOnCompletion: dismissOnCompletion)
			}))
		} else {
			alert.addAction(UIAlertAction(title: "Okay", style: .default, handler: nil))
		}
		
		self.present(alert, animated: true, completion: nil)
	}
	
}
