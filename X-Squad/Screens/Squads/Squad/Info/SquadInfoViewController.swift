//
//  SquadInfoViewController.swift
//  X-Squad
//
//  Created by Avario on 22/02/2019.
//  Copyright © 2019 Avario. All rights reserved.
//

import Foundation
import UIKit

struct SquadInfoAction {
	
	enum ActionType {
		case action(() -> Void, destructive: Bool)
		case toggle((Bool) -> Void, isOn: Bool)
	}
	
	let title: String
	let image: UIImage
	let type: ActionType
}

class SquadInfoViewController: UIViewController {
	
	let actions: [SquadInfoAction]
	
	init(actions: [SquadInfoAction]) {
		self.actions = actions
		super.init(nibName: nil, bundle: nil)
		
		modalPresentationStyle = .overCurrentContext
		transitioningDelegate = self
	}
	
	required init?(coder aDecoder: NSCoder) {
		fatalError()
	}
	
	var pullToDismissController: PullToDismissController!
	
	let scrollView = UIScrollView()
	let actionsStackView = UIStackView()
	var scrollViewTopConstraint: NSLayoutConstraint!
	let dimmingView = UIView()
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		view.backgroundColor = .clear
		
		scrollView.alwaysBounceVertical = true
		scrollView.contentInset.top = view.bounds.height
		scrollView.contentInsetAdjustmentBehavior = .never
		scrollView.delaysContentTouches = false
		view.addSubview(scrollView)
		
		scrollView.translatesAutoresizingMaskIntoConstraints = false
		scrollViewTopConstraint = scrollView.topAnchor.constraint(equalTo: view.topAnchor)
		scrollViewTopConstraint.isActive = true
		
		scrollView.rightAnchor.constraint(equalTo: view.rightAnchor).isActive = true
		scrollView.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
		scrollView.heightAnchor.constraint(equalTo: view.heightAnchor).isActive = true
		
		actionsStackView.axis = .vertical
		
		let separator = UIView()
		separator.backgroundColor = UIColor.white.withAlphaComponent(0.2)
		separator.translatesAutoresizingMaskIntoConstraints = false
		separator.heightAnchor.constraint(equalToConstant: 0.5).isActive = true
		actionsStackView.addArrangedSubview(separator)
		
		for action in actions {
			let actionButton = SquadInfoActionButton(action: action)
			actionsStackView.addArrangedSubview(actionButton)
			
			if case .action = action.type {
				actionButton.addTarget(self, action: #selector(performAction(for:)), for: .touchUpInside)
			}
		}
		
		scrollView.addSubview(actionsStackView)
		actionsStackView.translatesAutoresizingMaskIntoConstraints = false
		actionsStackView.topAnchor.constraint(equalTo: scrollView.topAnchor).isActive = true
		actionsStackView.rightAnchor.constraint(equalTo: scrollView.rightAnchor).isActive = true
		actionsStackView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor).isActive = true
		actionsStackView.leftAnchor.constraint(equalTo: scrollView.leftAnchor).isActive = true
		actionsStackView.widthAnchor.constraint(equalTo: scrollView.widthAnchor).isActive = true
		
		view.insertSubview(dimmingView, belowSubview: scrollView)
		
		dimmingView.translatesAutoresizingMaskIntoConstraints = false
		dimmingView.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
		dimmingView.rightAnchor.constraint(equalTo: view.rightAnchor).isActive = true
		dimmingView.bottomAnchor.constraint(equalTo: actionsStackView.topAnchor).isActive = true
		dimmingView.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
		
		pullToDismissController = PullToDismissController(scrollView: scrollView)
		pullToDismissController.viewController = self
		pullToDismissController.dimmingView = dimmingView
		
		let blurView = UIVisualEffectView(effect: UIBlurEffect(style: .dark))
		view.insertSubview(blurView, belowSubview: scrollView)
		
		blurView.translatesAutoresizingMaskIntoConstraints = false
		blurView.topAnchor.constraint(equalTo: actionsStackView.topAnchor).isActive = true
		blurView.rightAnchor.constraint(equalTo: view.rightAnchor).isActive = true
		blurView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor).isActive = true
		blurView.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
		
		let scrollViewTapGesture = UITapGestureRecognizer(target: self, action: #selector(scrollViewTapped))
		scrollView.addGestureRecognizer(scrollViewTapGesture)
	}
	
	@objc func performAction(for button: SquadInfoActionButton) {
		dismiss(animated: true) {
			if case let .action(callback, _) = button.action.type {
				callback()
			}
		}
	}
	
	@objc func scrollViewTapped() {
		dismiss(animated: true, completion: nil)
	}
}

extension SquadInfoViewController: UIViewControllerTransitioningDelegate {
	
	func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
		return SquadInfoPresentAnimationController()
	}
	
	func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
		return SquadInfoDismissAnimationController()
	}
	
}

class SquadInfoPresentAnimationController: NSObject, UIViewControllerAnimatedTransitioning {
	
	let transitionTime: TimeInterval = 0.5
	
	func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
		return transitionTime
	}
	
	func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
		
		guard let toVC = transitionContext.viewController(forKey: .to) as? SquadInfoViewController else {
			return
		}
		
		let containerView = transitionContext.containerView
		containerView.addSubview(toVC.view)
		
		toVC.dimmingView.alpha = 0
		toVC.actionsStackView.layoutIfNeeded()
		toVC.scrollView.contentInset.top = toVC.view.safeAreaInsets.top + toVC.view.safeAreaLayoutGuide.layoutFrame.height - toVC.actionsStackView.bounds.height
		
		toVC.scrollViewTopConstraint.constant = toVC.actionsStackView.bounds.height + toVC.view.safeAreaInsets.bottom
		
		toVC.view.layoutIfNeeded()
		
		UIView.animate(withDuration: transitionTime, delay: 0.0, usingSpringWithDamping: 1.0, initialSpringVelocity: 0, options: [], animations: {
			toVC.scrollViewTopConstraint.constant = 0
			toVC.view.layoutIfNeeded()
			
			toVC.dimmingView.alpha = 0.7
		}) { (_) in
			transitionContext.completeTransition(true)
		}
	}
}

class SquadInfoDismissAnimationController: NSObject, UIViewControllerAnimatedTransitioning {
	
	let transitionTime: TimeInterval = 0.5
	
	func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
		return transitionTime
	}
	
	func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
		
		guard let fromVC = transitionContext.viewController(forKey: .from) as? SquadInfoViewController else {
			return
		}
		
		UIView.animate(withDuration: transitionTime, delay: 0.0, usingSpringWithDamping: 1.0, initialSpringVelocity: 0, options: [], animations: {
			fromVC.scrollViewTopConstraint.constant = fromVC.actionsStackView.bounds.height + fromVC.view.safeAreaInsets.bottom
			fromVC.view.layoutIfNeeded()
			
			fromVC.dimmingView.alpha = 0
		}) { (_) in
			fromVC.view.removeFromSuperview()
			transitionContext.completeTransition(true)
		}
	}
}

