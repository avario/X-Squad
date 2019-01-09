//
//  CardsDismissAnimationController.swift
//  X-Squad
//
//  Created by Avario on 07/01/2019.
//  Copyright © 2019 Avario. All rights reserved.
//

import Foundation
import UIKit

class CardsDismissAnimationController: NSObject, UIViewControllerAnimatedTransitioning {
	
	let animator: UIDynamicAnimator
	var transitionContext: UIViewControllerContextTransitioning?
	var matchedToCardViews: [CardView] = []
	
	init(animator: UIDynamicAnimator) {
		self.animator = animator
		super.init()
		animator.delegate = self
	}
	
	let transitionTime: TimeInterval = 0.5
	
	func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
		return transitionTime
	}
	
	func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
		self.transitionContext = transitionContext
		guard let fromVC = transitionContext.viewController(forKey: .from),
			let toVC = transitionContext.viewController(forKey: .to)
			else {
				return
		}
		
		fromVC.view.isUserInteractionEnabled = false
		
		let fromCardViews = CardView.all(in: fromVC.view)
		let toCardViews = CardView.all(in: toVC.view)
		
		for fromCardView in fromCardViews {
			if let matchingToCardView = toCardViews.first(where: { $0.card == fromCardView.card }) {
				let cardPosition = matchingToCardView.superview!.convert(matchingToCardView.center, to: toVC.view)

				let snap = UISnapBehavior(item: fromCardView, snapTo: cardPosition)
				snap.damping = 0.5
				animator.addBehavior(snap)
				animator.addBehavior(fromCardView.behaviour)
				
				let scale = matchingToCardView.bounds.width/fromCardView.bounds.width
				UIView.animate(withDuration: transitionTime, delay: 0.0, usingSpringWithDamping: 0.8, initialSpringVelocity: 0, options: [], animations: {
					fromCardView.imageView.transform = CGAffineTransform(scaleX: scale, y: scale)
				}, completion: nil)
				
				matchingToCardView.isHidden = true
				matchedToCardViews.append(matchingToCardView)
				
			} else {
				// Maybe just fall or something?
			}
		}
		
		UIView.animate(withDuration: transitionTime/2) {
			for subview in fromVC.view.subviews {
				guard subview is CardView == false else {
					continue
				}
				subview.alpha = 0
			}
		}
		
		UIView.animate(withDuration: transitionTime, animations: {
			fromVC.view.backgroundColor = UIColor.black.withAlphaComponent(0)
		}) { (_) in
			self.transitionContext?.completeTransition(true)
			for matchingToCardView in self.matchedToCardViews {
				matchingToCardView.isHidden = false
			}
		}
	}
}

extension CardsDismissAnimationController: UIDynamicAnimatorDelegate {
	
	func dynamicAnimatorDidPause(_ animator: UIDynamicAnimator) {
//		transitionContext?.completeTransition(true)
//
//		for matchingToCardView in matchedToCardViews {
//			matchingToCardView.isHidden = false
//		}
	}
	
}
