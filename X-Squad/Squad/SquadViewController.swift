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
	
	private var animator = UIDynamicAnimator(referenceView: UIApplication.shared.keyWindow!)
	
	var squadPilotViews: [SquadPilotView] = []
	
	init(for squad: Squad) {
		self.squad = squad
		super.init(nibName: nil, bundle: nil)
		
		transitioningDelegate = self
		modalPresentationStyle = .overCurrentContext
	}
	
	required init?(coder aDecoder: NSCoder) {
		fatalError()
	}
	
	override var preferredStatusBarStyle: UIStatusBarStyle {
		return .lightContent
	}
	
	let scrollView = UIScrollView()
	let stackView = UIStackView()
	
	var pullToDismissController: PullToDismissController!
	
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
		
		let header = SquadHeaderView(squad: squad)
		stackView.addArrangedSubview(header)
		
		let addPilotButton = UIButton(type: .contactAdd)
		addPilotButton.addTarget(self, action: #selector(addPilot), for: .touchUpInside)
		addPilotButton.translatesAutoresizingMaskIntoConstraints = false
		addPilotButton.heightAnchor.constraint(equalToConstant: 100).isActive = true
		
		stackView.addArrangedSubview(addPilotButton)
		
		for pilot in squad.pilots.value {
			let squadPilotView = SquadPilotView(pilot: pilot)
			stackView.insertArrangedSubview(squadPilotView, at: stackView.arrangedSubviews.count - 1)
			
			squadPilotView.delegate = self
			
			squadPilotViews.append(squadPilotView)
		}
		
		pullToDismissController = PullToDismissController(viewController: self, scrollView: scrollView, animator: animator)
		pullToDismissController.delegate = self
	}
	
	@objc func addPilot() {
		let addPilotViewController = AddPilotViewController(squad: squad)
		present(addPilotViewController, animated: true, completion: nil)
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

extension SquadViewController: UIViewControllerTransitioningDelegate {
	
	func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
		return CardsPresentAnimationController(animator: animator)
	}
	
	func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
		return CardsDismissAnimationController(animator: animator)
	}
	
	func interactionControllerForDismissal(using animator: UIViewControllerAnimatedTransitioning) -> UIViewControllerInteractiveTransitioning? {
		return nil
	}
}

extension SquadViewController: PullToDismissControllerDelegate {
	func pullToDismissControllerWillBeginPullGesture(_ pullToDismissController: PullToDismissController) {
		for squadPilotView in squadPilotViews {
			squadPilotView.scrollView.panGestureRecognizer.isEnabled = false
		}
	}
	
	func pullToDismissControllerWillCancelPullGesture(_ pullToDismissController: PullToDismissController) {
		for squadPilotView in squadPilotViews {
			squadPilotView.scrollView.panGestureRecognizer.isEnabled = true
			squadPilotView.scrollView.contentOffset = .zero
		}
	}
}
