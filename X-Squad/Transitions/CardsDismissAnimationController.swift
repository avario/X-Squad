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
	
	let animator = UIDynamicAnimator(referenceView: UIApplication.shared.keyWindow!)
	var transitionContext: UIViewControllerContextTransitioning?
	var matchedToCardViews: [CardView] = []
	
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
			var targetAlpha: CGFloat = 1.0
			var targetScale: CGFloat = 0.001
			
			if let matchingToCardView = toCardViews.first(where: { $0.id == fromCardView.id }) {
				let cardPosition = matchingToCardView.superview!.convert(matchingToCardView.center, to: toVC.view)

				fromCardView.snap.snapPoint = cardPosition
				animator.addBehavior(fromCardView.snap)
				animator.addBehavior(fromCardView.behaviour)
				
				targetScale = matchingToCardView.bounds.width/fromCardView.bounds.width
				targetAlpha = matchingToCardView.alpha
				
				matchingToCardView.isHidden = true
				matchedToCardViews.append(matchingToCardView)
			
				UIView.animate(withDuration: transitionTime, delay: 0.0, usingSpringWithDamping: 0.8, initialSpringVelocity: 0, options: [], animations: {
					fromCardView.imageView.transform = CGAffineTransform(scaleX: targetScale, y: targetScale)
					fromCardView.alpha = targetAlpha
				}, completion: nil)
			} else {
				UIView.animate(withDuration: transitionTime, delay: 0.0, usingSpringWithDamping: 1.0, initialSpringVelocity: 0, options: [], animations: {
					fromCardView.center = CGPoint(
						x: fromCardView.center.x,
						y: fromCardView.center.y + UIScreen.main.bounds.height)
				}, completion: nil)
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
