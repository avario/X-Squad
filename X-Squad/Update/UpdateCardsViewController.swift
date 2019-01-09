//
//  UpdateCardsViewController.swift
//  X-Squad
//
//  Created by Avario on 03/01/2019.
//  Copyright © 2019 Avario. All rights reserved.
//

import Foundation
import UIKit

class UpdateCardsViewController: UIViewController {
	
	let activityIndicator = UIActivityIndicatorView(style: .white)
	
	init() {
		super.init(nibName: nil, bundle: nil)
		
		title = "Update Database"
		navigationItem.hidesBackButton = true
		navigationController?.interactivePopGestureRecognizer?.isEnabled = false
		
		
	}
	
	required init?(coder aDecoder: NSCoder) {
		fatalError()
	}
	
	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
		navigationController?.setNavigationBarHidden(true, animated: animated)
	}
	
	override func viewWillDisappear(_ animated: Bool) {
		super.viewWillDisappear(animated)
		navigationController?.setNavigationBarHidden(false, animated: animated)
	}
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		view.backgroundColor = .black
		
		activityIndicator.translatesAutoresizingMaskIntoConstraints = false
		view.addSubview(activityIndicator)
		
		activityIndicator.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
		activityIndicator.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
		
		let label = UILabel()
		label.translatesAutoresizingMaskIntoConstraints = false
		label.textColor = UIColor.white.withAlphaComponent(0.8)
		label.textAlignment = .center
		label.text = "Updating card database..."
		
		view.addSubview(label)
		label.topAnchor.constraint(equalTo: activityIndicator.bottomAnchor, constant: 20).isActive = true
		label.centerXAnchor.constraint(equalTo: activityIndicator.centerXAnchor).isActive = true
	}
	
	override var preferredStatusBarStyle: UIStatusBarStyle {
		return .lightContent
	}
	
	func update(dismissOnCompletion: Bool) {
		activityIndicator.startAnimating()
		CardStore.update { (result) in
			if dismissOnCompletion {
				self.navigationController?.popViewController(animated: true)
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
		let darkNavigation = UINavigationController(navigationBarClass: DarkNavigationBar.self, toolbarClass: nil)
		darkNavigation.viewControllers = [LibraryViewController()]
		window.rootViewController = darkNavigation
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
