//
//  DownloadViewController.swift
//  X-Squad
//
//  Created by Avario on 08/01/2019.
//  Copyright © 2019 Avario. All rights reserved.
//

import Foundation
import UIKit

class DownloadViewController: UIViewController {
	
	let progressView = UIProgressView()
	let label = UILabel()
	let activityIndicator = UIActivityIndicatorView(style: .white)
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		view.backgroundColor = UIColor(named: "XBackground")
		navigationController?.navigationBar.barStyle = .black
		
		view.addSubview(progressView)
		progressView.translatesAutoresizingMaskIntoConstraints = false
		
		progressView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
		progressView.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
		progressView.widthAnchor.constraint(equalTo: view.widthAnchor, constant: -20).isActive = true
		
		label.translatesAutoresizingMaskIntoConstraints = false
		label.textColor = UIColor.white.withAlphaComponent(0.8)
		label.textAlignment = .center
		
		view.addSubview(label)
		label.bottomAnchor.constraint(equalTo: progressView.topAnchor, constant: -20).isActive = true
		label.centerXAnchor.constraint(equalTo: progressView.centerXAnchor).isActive = true
		
		activityIndicator.translatesAutoresizingMaskIntoConstraints = false
		view.addSubview(activityIndicator)
		
		activityIndicator.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
		activityIndicator.bottomAnchor.constraint(equalTo: label.topAnchor, constant: -20).isActive = true
	}
	
	override var preferredStatusBarStyle: UIStatusBarStyle {
		return .lightContent
	}
	
}
