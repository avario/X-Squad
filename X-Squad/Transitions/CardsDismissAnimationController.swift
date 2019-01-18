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
		
//		animator.setValue(true, forKey: "debugEnabled")
		
		fromVC.view.isUserInteractionEnabled = false
		
		let fromCardViews = CardView.all(in: fromVC.view)
		let toCardViews = CardView.all(in: toVC.view)
		
		var viewsToAnimateOut: [UIView] = []
		
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
				viewsToAnimateOut.append(fromCardView)
				
				
			}
		}
		
//		viewsToAnimateOut.append(contentsOf: fromVC.view.allHUDViews())
		
		for view in viewsToAnimateOut {
			UIView.animate(withDuration: transitionTime, delay: 0.0, usingSpringWithDamping: 1.0, initialSpringVelocity: 0, options: [], animations: {
				view.center = CGPoint(
					x: view.center.x,
					y: view.center.y + UIScreen.main.bounds.height)
			}, completion: nil)
		}
		
		for view in fromVC.view.allHUDViews() {
			UIView.animate(withDuration: transitionTime, delay: 0.0, usingSpringWithDamping: 1.0, initialSpringVelocity: 0, options: [], animations: {
				view.alpha = 0
			}, completion: nil)
		}
		
		UIView.animate(withDuration: transitionTime, animations: {
			fromVC.view.backgroundColor = UIColor.black.withAlphaComponent(0)
		}) { (_) in
			for matchingToCardView in self.matchedToCardViews {
				matchingToCardView.isHidden = false
			}
			
			if toVC is SquadViewController,
				let matchedCardView = self.matchedToCardViews.first,
				matchedCardView.card?.type == .upgrade,
				let snapshot = matchedCardView.snapshotView(afterScreenUpdates: true) {
				matchedCardView.superview?.addSubview(snapshot)
				snapshot.center = matchedCardView.center
				snapshot.isUserInteractionEnabled = false
				
				UIView.animate(withDuration: 0.2, animations: {
					snapshot.alpha = 0
				}, completion: { (_) in
					snapshot.removeFromSuperview()
				})
			}
			
			self.transitionContext?.completeTransition(true)
		}
	}
}
