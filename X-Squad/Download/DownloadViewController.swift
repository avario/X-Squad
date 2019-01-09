//
//  DownloadViewController.swift
//  X-Squad
//
//  Created by Avario on 08/01/2019.
//  Copyright © 2019 Avario. All rights reserved.
//

import Foundation
import UIKit
import Kingfisher

class DownloadViewController: UIViewController {
	
	let progessView = UIProgressView()
	let label = UILabel()
	let activityIndicator = UIActivityIndicatorView(style: .white)
	
	var currentDownloadTask: Kingfisher.DownloadTask?
	var cancelled = false
	
	init() {
		super.init(nibName: nil, bundle: nil)
		
		title = "Download"
		
		let cancelButton = UIBarButtonItem(title: "Cancel", style: .plain, target: self, action: #selector(cancel))
		navigationItem.rightBarButtonItem = cancelButton
	}
	
	required init?(coder aDecoder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		view.backgroundColor = .black
		
		view.addSubview(progessView)
		progessView.translatesAutoresizingMaskIntoConstraints = false
		
		progessView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
		progessView.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
		progessView.widthAnchor.constraint(equalTo: view.widthAnchor, constant: -20).isActive = true
		
		label.translatesAutoresizingMaskIntoConstraints = false
		label.textColor = UIColor.white.withAlphaComponent(0.8)
		label.textAlignment = .center
		
		view.addSubview(label)
		label.bottomAnchor.constraint(equalTo: progessView.topAnchor, constant: -20).isActive = true
		label.centerXAnchor.constraint(equalTo: progessView.centerXAnchor).isActive = true
		
		activityIndicator.translatesAutoresizingMaskIntoConstraints = false
		view.addSubview(activityIndicator)
		
		activityIndicator.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
		activityIndicator.bottomAnchor.constraint(equalTo: label.topAnchor, constant: -20).isActive = true
	}
	
	override func viewDidAppear(_ animated: Bool) {
		super.viewDidAppear(animated)
		downloadCardImages()
	}
	
	@objc func cancel() {
		cancelled = true
		currentDownloadTask?.cancel()
		dismiss(animated: true, completion: nil)
	}
	
	func downloadCardImages() {
		activityIndicator.startAnimating()
		downloadCardImage(for: 0)
	}
	
	func downloadCardImage(for index: Int) {
		guard CardStore.cards.count > index else {
			finishDownload()
			return
		}
		
		let card = CardStore.cards[index]
		label.text = "Downloading card \(index + 1) of \(CardStore.cards.count)"
		
		currentDownloadTask = KingfisherManager.shared.retrieveImage(with: card.cardImageURL) { result in
			DispatchQueue.main.async {
				switch result {
				case .success:
					guard self.cancelled == false else {
						return
					}
					
					self.progessView.progress = Float(index + 1)/Float(CardStore.cards.count)
					self.downloadCardImage(for: index + 1)
					
				case .failure(let error):
					switch error {
					case .requestError:
						// Cancelled
						return
					default:
						break
					}
					
					let alert = UIAlertController(title: "Images Download Failed", message: "Please check your network connection and try again. Any images that were successfully downloaded have been saved.", preferredStyle: .alert)
					alert.addAction(UIAlertAction(title: "Okay", style: .default) { _ in
						self.presentingViewController?.dismiss(animated: true, completion: nil)
					})
					self.present(alert, animated: true, completion: nil)
				}
			}
		}
	}
	
	func finishDownload() {
		activityIndicator.stopAnimating()
		label.text = "Downloading Complete"
		let alert = UIAlertController(title: "Download Completed", message: "All card images have been saved.", preferredStyle: .alert)
		alert.addAction(UIAlertAction(title: "Okay", style: .default) { _ in
			self.presentingViewController?.dismiss(animated: true, completion: nil)
		})
		self.present(alert, animated: true, completion: nil)
	}
	
}
