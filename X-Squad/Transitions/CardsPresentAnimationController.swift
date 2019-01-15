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
	
	let transitionPoint: CGPoint
	
	init(animator: UIDynamicAnimator, transitionPoint: CGPoint = .zero) {
		self.transitionPoint = transitionPoint
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
		
		toVC.view.layoutIfNeeded()
		
		let fromCardViews = CardView.all(in: fromVC.view)
		let toCardViews = CardView.all(in: toVC.view)
		
		for toCardView in toCardViews {
			
			toCardView.snap.snapPoint = toCardView.superview!.convert(toCardView.center, to: animator.referenceView)
			let targetAlpha = toCardView.alpha
			
			if let matchingFromCardView = fromCardViews.first(where: { $0.id == toCardView.id }) {
				
				let fromCardPosition = matchingFromCardView.superview!.convert(matchingFromCardView.center, to: fromVC.view)
				toCardView.center = toVC.view.convert(fromCardPosition, to: toCardView.superview)
				
				let scale = matchingFromCardView.bounds.width/toCardView.bounds.width
				toCardView.imageView.transform = CGAffineTransform(scaleX: scale, y: scale)
				
				toCardView.alpha = matchingFromCardView.alpha
				
				matchingFromCardView.isHidden = true
			
				animator.addBehavior(toCardView.snap)
				animator.addBehavior(toCardView.behaviour)
				
				UIView.animate(withDuration: transitionTime, delay: 0.0, usingSpringWithDamping: 0.8, initialSpringVelocity: 0, options: [], animations: {
					toCardView.imageView.transform = CGAffineTransform.identity
					toCardView.alpha = targetAlpha
				}, completion: nil)
				
			} else {
				let targetLocation = toCardView.center
				toCardView.center = CGPoint(
					x: targetLocation.x,
					y: targetLocation.y + UIScreen.main.bounds.height)
				
				UIView.animate(withDuration: transitionTime, delay: 0.0, usingSpringWithDamping: 1.0, initialSpringVelocity: 0, options: [], animations: {
					toCardView.center = targetLocation
				}, completion: nil)
			}
		}
		
		let viewsToFade = toVC.view.allHUDViews()
		for view in viewsToFade {
			view.alpha = 0
		}
		
		toVC.view.backgroundColor = UIColor.black.withAlphaComponent(0)
		UIView.animate(withDuration: transitionTime, animations: {
			toVC.view.backgroundColor = .black
			for view in viewsToFade {
				view.alpha = 1.0
			}
		}) { (_) in
			transitionContext.completeTransition(true)
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
