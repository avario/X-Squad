//
//  SquadViewController.swift
//  X-Squad
//
//  Created by Avario on 10/01/2019.
//  Copyright © 2019 Avario. All rights reserved.
//

import Foundation
import UIKit

class SquadViewController: UIViewController {
	
	let squad: Squad
	
	static let pilotCardWidth = UIScreen.main.bounds.width * 0.5
	
	init(for squad: Squad) {
		self.squad = squad
		super.init(nibName: nil, bundle: nil)
	}
	
	required init?(coder aDecoder: NSCoder) {
		fatalError()
	}
	
	override var preferredStatusBarStyle: UIStatusBarStyle {
		return .lightContent
	}
	
	let scrollView = UIScrollView()
	let stackView = UIStackView()
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		view.backgroundColor = .black
		
		view.addSubview(scrollView)
		scrollView.contentInsetAdjustmentBehavior = .always
		scrollView.translatesAutoresizingMaskIntoConstraints = false
		scrollView.alwaysBounceVertical = true
		
		scrollView.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
		scrollView.rightAnchor.constraint(equalTo: view.rightAnchor).isActive = true
		scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
		scrollView.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
		
		scrollView.addSubview(stackView)
		stackView.translatesAutoresizingMaskIntoConstraints = false
		stackView.axis = .vertical
		stackView.spacing = 10
		stackView.alignment = .fill
		
		stackView.topAnchor.constraint(equalTo: scrollView.topAnchor).isActive = true
		stackView.rightAnchor.constraint(equalTo: scrollView.rightAnchor).isActive = true
		stackView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor).isActive = true
		stackView.leftAnchor.constraint(equalTo: scrollView.leftAnchor).isActive = true
		stackView.widthAnchor.constraint(equalTo: scrollView.widthAnchor).isActive = true
		
		let panGesture = UIPanGestureRecognizer(target: self, action: #selector(panSquad(recognizer:)))
		panGesture.maximumNumberOfTouches = 1
		panGesture.delegate = self
		scrollView.addGestureRecognizer(panGesture)
		
		let header = SquadHeaderView(squad: squad)
		stackView.addArrangedSubview(header)
		
		let addPilotButton = UIButton(type: .contactAdd)
		addPilotButton.addTarget(self, action: #selector(addPilot), for: .touchUpInside)
		addPilotButton.translatesAutoresizingMaskIntoConstraints = false
		addPilotButton.heightAnchor.constraint(equalToConstant: 100).isActive = true
		
		stackView.addArrangedSubview(addPilotButton)
		
		for pilot in squad.pilots.value {
			let squadPilotView = SquadPilotView(pilot: pilot)
			stackView.insertArrangedSubview(squadPilotView, at: 1)
			
			squadPilotView.delegate = self
		}
	}
	
	@objc func panSquad(recognizer: UIPanGestureRecognizer) {
		switch recognizer.state {
		case .began:
			break
			
		case .changed:
			break
			
		case .cancelled, .ended, .failed:
			let velocity = recognizer.velocity(in: view)
			if velocity.y > 500 {
				dismiss(animated: true, completion: nil)
			}
		case.possible:
			break
		}
	}
	
	@objc func addPilot() {
		let addPilotViewController = AddPilotViewController(squad: squad)
		present(addPilotViewController, animated: true, completion: nil)
	}
	
}

extension SquadViewController: UIGestureRecognizerDelegate {
	
	func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
		guard let panGesture = gestureRecognizer as? UIPanGestureRecognizer else {
			return true
		}
		
		if scrollView.contentOffset.y <= -scrollView.adjustedContentInset.top,
			panGesture.velocity(in: nil).y >= 0 {
			return true
		}
		
		// Scroll as normal
		return false
	}
	
	func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
		return otherGestureRecognizer == scrollView.panGestureRecognizer
	}
	
}

extension SquadViewController: SquadPilotViewDelegate {
	func squadPilotView(_ squadPilotView: SquadPilotView, didSelect pilot: Squad.Pilot) {
		guard let card = pilot.card else {
			return
		}
		
		let cardViewController = CardViewController(card: card, id: pilot.uuid.uuidString)
		present(cardViewController, animated: true, completion: nil)
	}
	
	func squadPilotView(_ squadPilotView: SquadPilotView, didSelect upgrade: Squad.Pilot.Upgrade) {
		guard let card = upgrade.card else {
			return
		}
		
		let cardViewController = CardViewController(card: card, id: upgrade.uuid.uuidString)
		present(cardViewController, animated: true, completion: nil)
	}
	
	func squadPilotView(_ squadPilotView: SquadPilotView, didPressButtonFor upgradeType: Card.UpgradeType) {
		let addUpgradeViewController = AddUpgradeViewController(squad: squad, pilot: squadPilotView.pilot, upgradeType: upgradeType)
		present(addUpgradeViewController, animated: true, completion: nil)
	}
}
