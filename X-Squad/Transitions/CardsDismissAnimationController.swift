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
			animator.addBehavior(fromCardView.behaviour)
			
			if let matchingToCardView = toCardViews.first(where: { $0.id == fromCardView.id }) {
				let cardPosition = matchingToCardView.superview!.convert(matchingToCardView.center, to: toVC.view)

				let snap = UISnapBehavior(item: fromCardView, snapTo: cardPosition)
				snap.damping = 0.5
				animator.addBehavior(snap)
				
				let scale = matchingToCardView.bounds.width/fromCardView.bounds.width
				UIView.animate(withDuration: transitionTime, delay: 0.0, usingSpringWithDamping: 0.8, initialSpringVelocity: 0, options: [], animations: {
					fromCardView.imageView.transform = CGAffineTransform(scaleX: scale, y: scale)
					fromCardView.alpha = matchingToCardView.alpha
				}, completion: nil)
				
				matchingToCardView.isHidden = true
				matchedToCardViews.append(matchingToCardView)
				
			} else {
				let snap = UISnapBehavior(item: fromCardView, snapTo: CGPoint(x: CGFloat.random(in: -100...(UIScreen.main.bounds.width + 100)), y: UIScreen.main.bounds.height + fromCardView.bounds.height))
				snap.damping = 0.5
				animator.addBehavior(snap)
			}
		}
		
		let viewsToFade = fromVC.view.allHUDViews()
		UIView.animate(withDuration: transitionTime/2) {
			for view in viewsToFade {
				view.alpha = 0
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
