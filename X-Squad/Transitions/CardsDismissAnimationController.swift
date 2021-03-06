//
//  CardsDismissAnimationController.swift
//  X-Squad
//
//  Created by Avario on 07/01/2019.
//  Copyright © 2019 Avario. All rights reserved.
//
// This handles the custom transition when dismissing cards (the card animate from their previous positions and sizes to their new ones).

import Foundation
import UIKit

class CardsDismissAnimationController: NSObject, UIViewControllerAnimatedTransitioning {
	
	let animator = UIDynamicAnimator(referenceView: UIApplication.shared.keyWindow!)
	
	let transitionTime: TimeInterval = 0.5
	
	let targetViewController: UIViewController?
	
	enum Style {
		case smooth
		case physics
	}
	
	let style: Style
	
	init(targetViewController: UIViewController? = nil, style: Style = .smooth) {
		self.style = style
		self.targetViewController = targetViewController
		super.init()
	}
	
	func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
		return transitionTime
	}
	
	func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
		guard let fromVC = transitionContext.viewController(forKey: .from),
			let toVC = targetViewController ?? transitionContext.viewController(forKey: .to)
			else {
				return
		}
		
		fromVC.view.isUserInteractionEnabled = false
		
		let fromCardViews = CardView.all(in: fromVC.view)
		let toCardViews = CardView.all(in: toVC.view)
		
		var viewsToAnimateOut: [UIView] = []
		var matchedToCardViews: [CardView] = []
		
		for fromCardView in fromCardViews {
			var targetAlpha: CGFloat = 1.0
			var targetScale: CGFloat = 0.001
			
			if let matchingToCardView = toCardViews.first(where: { fromCardView.matches($0) }) {
				let cardPosition = matchingToCardView.superview!.convert(matchingToCardView.center, to: toVC.view)

				if style == .physics {
					let snap = UISnapBehavior(item: fromCardView, snapTo: cardPosition)
					animator.addBehavior(snap)
					
					let behaviour = UIDynamicItemBehavior(items: [fromCardView])
					behaviour.resistance = 10.0
					animator.addBehavior(behaviour)
				}
				
				targetScale = matchingToCardView.bounds.width/fromCardView.bounds.width
				targetAlpha = matchingToCardView.alpha
				
				matchingToCardView.isHidden = true
				matchedToCardViews.append(matchingToCardView)
				
				matchingToCardView.side = fromCardView.side
			
				UIView.animate(withDuration: transitionTime, delay: 0.0, usingSpringWithDamping: 0.8, initialSpringVelocity: 0, options: [], animations: {
					if self.style == .smooth {
						fromCardView.center = self.animator.referenceView!.convert(cardPosition, to: fromCardView.superview!)
					}
					
					fromCardView.cardContainer.transform = CGAffineTransform(scaleX: targetScale, y: targetScale)
					fromCardView.alpha = targetAlpha
				}, completion: nil)
			} else {
				viewsToAnimateOut.append(fromCardView)
			}
		}
		
		UIView.animate(withDuration: transitionTime, delay: 0.0, usingSpringWithDamping: 1.0, initialSpringVelocity: 0, options: [], animations: {
			for view in viewsToAnimateOut {
				view.center = CGPoint(
					x: view.center.x,
					y: view.center.y + UIScreen.main.bounds.height)
				view.alpha = 0
			}
		}, completion: nil)
		
		for view in fromVC.view.allHUDViews() {
			UIView.animate(withDuration: transitionTime, delay: 0.0, usingSpringWithDamping: 1.0, initialSpringVelocity: 0, options: [], animations: {
				view.alpha = 0
			}, completion: nil)
		}
		
		UIView.animate(withDuration: transitionTime, animations: {
			fromVC.view.backgroundColor = UIColor.black.withAlphaComponent(0)
		}) { (_) in
			for matchingToCardView in matchedToCardViews {
				matchingToCardView.isHidden = false
			}
			
			if toVC is SquadViewController,
				let matchedCardView = matchedToCardViews.first,
				matchedCardView.card is Upgrade,
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
			
			transitionContext.completeTransition(true)
		}
	}
}
