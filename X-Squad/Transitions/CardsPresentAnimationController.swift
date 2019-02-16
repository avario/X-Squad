//
//  CardsPresentAnimationController.swift
//  X-Squad
//
//  Created by Avario on 07/01/2019.
//  Copyright © 2019 Avario. All rights reserved.
//
// This handles the custom transition when presenting cards (the card animate from their previous positions and sizes to their new ones).

import Foundation
import UIKit

class CardsPresentAnimationController: NSObject, UIViewControllerAnimatedTransitioning {
	
	let animator = UIDynamicAnimator(referenceView: UIApplication.shared.keyWindow!)
	var transitionContext: UIViewControllerContextTransitioning?
	
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
		
//		animator.setValue(true, forKey: "debugEnabled")
		
		let containerView = transitionContext.containerView
		containerView.addSubview(toVC.view)
		
		toVC.view.layoutIfNeeded()
		
		let fromCardViews = CardView.all(in: fromVC.view)
		let toCardViews = CardView.all(in: toVC.view)
		
		var viewsToAnimateIn: [UIView] = []
		
		var snappedCardViews: [CardView] = []
		
		for toCardView in toCardViews {
			
			toCardView.snap.snapPoint = toCardView.superview!.convert(toCardView.center, to: animator.referenceView)
			let targetAlpha = toCardView.alpha
			
			if let matchingFromCardView = fromCardViews.first(where: { toCardView.matches($0) }) {
				
				let fromCardPosition = matchingFromCardView.superview!.convert(matchingFromCardView.center, to: fromVC.view)
				toCardView.center = toVC.view.convert(fromCardPosition, to: toCardView.superview)
				
				let scale = matchingFromCardView.bounds.width/toCardView.bounds.width
				toCardView.cardContainer.transform = CGAffineTransform(scaleX: scale, y: scale)
				
				toCardView.alpha = matchingFromCardView.alpha
				
				matchingFromCardView.isHidden = true
			
				animator.addBehavior(toCardView.snap)
				animator.addBehavior(toCardView.behaviour)
				
				UIView.animate(withDuration: transitionTime, delay: 0.0, usingSpringWithDamping: 0.8, initialSpringVelocity: 0, options: [], animations: {
					toCardView.cardContainer.transform = CGAffineTransform.identity
					toCardView.alpha = targetAlpha
				}, completion: nil)
				
				snappedCardViews.append(toCardView)
				
			} else {
				viewsToAnimateIn.append(toCardView)
			}
		}
		
//		viewsToAnimateIn.append(contentsOf: toVC.view.allHUDViews())
		
		for view in viewsToAnimateIn {
			let targetLocation = view.center
			view.center = CGPoint(
				x: targetLocation.x,
				y: targetLocation.y + UIScreen.main.bounds.height)
			
			UIView.animate(withDuration: transitionTime, delay: 0.0, usingSpringWithDamping: 1.0, initialSpringVelocity: 0, options: [], animations: {
				view.center = targetLocation
			}, completion: nil)
		}
		
		for view in toVC.view.allHUDViews() {
			view.alpha = 0
			
			UIView.animate(withDuration: transitionTime, delay: 0.0, usingSpringWithDamping: 1.0, initialSpringVelocity: 0, options: [], animations: {
				view.alpha = 1.0
			}, completion: nil)
		}
		
		toVC.view.backgroundColor = UIColor(named: "XBackground")!.withAlphaComponent(0)
		UIView.animate(withDuration: transitionTime, animations: {
			toVC.view.backgroundColor = UIColor(named: "XBackground")
		}) { (_) in
			transitionContext.completeTransition(true)
			
			UIView.animate(withDuration: 0.1, animations: {
				for cardView in snappedCardViews {
					cardView.center = self.animator.referenceView!.convert(cardView.snap.snapPoint, to: cardView.superview!)
					cardView.transform = .identity
				}
			})
		}
	}
}

extension UIView {
	
	func allHUDViews() -> [UIView] {
		var views: [UIView] = []
		for subview in subviews {
			if subview is UIButton || subview is CostView || subview is UILabel {
				views.append(subview)
			} else {
				views.append(contentsOf: subview.allHUDViews())
			}
		}
		
		return views
	}
	
}
