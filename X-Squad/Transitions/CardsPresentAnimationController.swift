//
//  CardsPresentAnimationController.swift
//  X-Squad
//
//  Created by Avario on 07/01/2019.
//  Copyright © 2019 Avario. All rights reserved.
//

import Foundation
import UIKit

class CardsPresentAnimationController: NSObject, UIViewControllerAnimatedTransitioning {
	
	
	let animator: UIDynamicAnimator
	var transitionContext: UIViewControllerContextTransitioning?
	var matchedFromCardViews: [CardView] = []
	
	init(animator: UIDynamicAnimator) {
		self.animator = animator
		super.init()
	}
	
	let transitionTime: TimeInterval = 0.5
	
	func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
		return transitionTime
	}
	
	func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
		
		guard let fromVC = transitionContext.viewController(forKey: .from),
			let toVC = transitionContext.viewController(forKey: .to)
			else {
				return
		}
		
		let containerView = transitionContext.containerView
		containerView.addSubview(toVC.view)
		
		let fromCardViews = CardView.all(in: fromVC.view)
		let toCardViews = CardView.all(in: toVC.view)
		
		for toCardView in toCardViews {
			if let matchingFromCardView = fromCardViews.first(where: { $0.card == toCardView.card }) {
				let fromCardPosition = matchingFromCardView.superview!.convert(matchingFromCardView.center, to: fromVC.view)
				toCardView.center = fromCardPosition
				
				let scale = matchingFromCardView.bounds.width/toCardView.bounds.width
				toCardView.imageView.transform = CGAffineTransform(scaleX: scale, y: scale)
				
				UIView.animate(withDuration: transitionTime, delay: 0.0, usingSpringWithDamping: 0.8, initialSpringVelocity: 0, options: [], animations: {
					toCardView.imageView.transform = CGAffineTransform.identity
				}, completion: nil)
				
				animator.addBehavior(toCardView.snap)
				animator.addBehavior(toCardView.behaviour)
				
				matchingFromCardView.isHidden = true
				matchedFromCardViews.append(matchingFromCardView)
				
			} else {
				// Maybe just fall or something?
			}
		}
		
		for subview in toVC.view.subviews {
			guard subview is CardView == false else {
				continue
			}
			subview.alpha = 0
		}
		
		toVC.view.backgroundColor = UIColor.black.withAlphaComponent(0)
		UIView.animate(withDuration: transitionTime, animations: {
			toVC.view.backgroundColor = .black
			for subview in toVC.view.subviews {
				guard subview is CardView == false else {
					continue
				}
				subview.alpha = 1.0
			}
		}) { (_) in
			transitionContext.completeTransition(true)
		}
	}
}
