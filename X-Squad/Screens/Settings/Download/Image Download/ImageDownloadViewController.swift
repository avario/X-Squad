//
//  ImageDownloadViewController.swift
//  X-Squad
//
//  Created by Avario on 09/01/2019.
//  Copyright © 2019 Avario. All rights reserved.
//

import Foundation
import UIKit
import Kingfisher

class ImageDownloadViewController: DownloadViewController {
	
	var currentDownloadTask: Kingfisher.DownloadTask?
	var cancelled = false
	
	init() {
		super.init(nibName: nil, bundle: nil)
		
		title = "Download Cards"
		
		let cancelButton = UIBarButtonItem(title: "Cancel", style: .plain, target: self, action: #selector(cancel))
		navigationItem.rightBarButtonItem = cancelButton
	}
	
	required init?(coder aDecoder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
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
		guard DataStore.allCards.count > index else {
			finishDownload()
			return
		}
		
		let card = DataStore.allCards[index]
		
		guard let imageURL = card.image else {
			self.downloadCardImage(for: index + 1)
			return
		}
		
		label.text = "Downloading card \(index + 1) of \(DataStore.allCards.count)"
		
		currentDownloadTask = KingfisherManager.shared.retrieveImage(with: imageURL) { result in
			DispatchQueue.main.async {
				switch result {
				case .success:
					guard self.cancelled == false else {
						return
					}
					
					self.progressView.progress = Float(index + 1)/Float(DataStore.allCards.count)
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
