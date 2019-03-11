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
	
	enum Style {
		case smooth
		case physics
	}
	
	let style: Style
	
	init(style: Style = .smooth) {
		self.style = style
		super.init()
	}
	
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
		
		var viewsToAnimateIn: [UIView] = []
		
		var snappedCardViews: [CardView] = []
		
		for toCardView in toCardViews {
			
			let position = toCardView.superview!.convert(toCardView.center, to: animator.referenceView)
			let targetAlpha = toCardView.alpha
			
			if let matchingFromCardView = fromCardViews.first(where: { toCardView.matches($0) }) {
				
				let fromCardPosition = matchingFromCardView.superview!.convert(matchingFromCardView.center, to: fromVC.view)
				toCardView.center = toVC.view.convert(fromCardPosition, to: toCardView.superview)
				
				let scale = matchingFromCardView.bounds.width/toCardView.bounds.width
				toCardView.cardContainer.transform = CGAffineTransform(scaleX: scale, y: scale)
				
				toCardView.alpha = matchingFromCardView.alpha
				
				matchingFromCardView.isHidden = true
				toCardView.side = matchingFromCardView.side
			
				if style == .physics {
					let snap = UISnapBehavior(item: toCardView, snapTo: position)
					animator.addBehavior(snap)

					let behaviour = UIDynamicItemBehavior(items: [toCardView])
					behaviour.resistance = 10.0
					animator.addBehavior(behaviour)
				}
				
				UIView.animate(withDuration: transitionTime, delay: 0.0, usingSpringWithDamping: 0.8, initialSpringVelocity: 0, options: [], animations: {
					if self.style == .smooth {
						toCardView.center = self.animator.referenceView!.convert(position, to: toCardView.superview!)
					}
					
					toCardView.cardContainer.transform = CGAffineTransform.identity
					toCardView.alpha = targetAlpha
				}, completion: { _ in
					if self.style == .physics {
						// Sometimes the physics hasn't quite settled the card into its final position so this animation sets it straight.
						UIView.animate(withDuration: 0.1, animations: {
							toCardView.center = self.animator.referenceView!.convert(position, to: toCardView.superview!)
							toCardView.transform = .identity
						}, completion: nil)
					}
				})
				
				snappedCardViews.append(toCardView)
			} else {
				viewsToAnimateIn.append(toCardView)
			}
		}
		
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
		
		toVC.view.backgroundColor = UIColor.black.withAlphaComponent(0)
		UIView.animate(withDuration: transitionTime, animations: {
			toVC.view.backgroundColor = .black
		}) { (_) in
			transitionContext.completeTransition(true)
		}
	}
}

extension UIView {
	
	func allHUDViews() -> [UIView] {
		var views: [UIView] = []
		for subview in subviews {
			if subview is UIButton || subview is CostView || subview is UILabel || subview is UIImageView {
				views.append(subview)
			} else if subview is CardView == false {
				views.append(contentsOf: subview.allHUDViews())
			}
		}
		
		return views
	}
	
}
