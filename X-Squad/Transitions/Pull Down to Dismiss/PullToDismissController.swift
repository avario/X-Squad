//
//  PullToDismissController.swift
//  X-Squad
//
//  Created by Avario on 15/01/2019.
//  Copyright © 2019 Avario. All rights reserved.
//

import Foundation
import UIKit

protocol PullToDismissControllerDelegate: AnyObject {
	func pullToDismissControllerWillBeginPullGesture(_ pullToDismissController: PullToDismissController)
	func pullToDismissControllerWillCancelPullGesture(_ pullToDismissController: PullToDismissController)
}

extension PullToDismissControllerDelegate {
	func pullToDismissControllerWillBeginPullGesture(_ pullToDismissController: PullToDismissController) { }
	func pullToDismissControllerWillCancelPullGesture(_ pullToDismissController: PullToDismissController) { }
}

class PullToDismissController: NSObject {
	
	weak var delegate: PullToDismissControllerDelegate?
	
	weak var viewController: UIViewController?
	let scrollView: UIScrollView
	let animator: UIDynamicAnimator
	
	init(viewController: UIViewController, scrollView: UIScrollView, animator: UIDynamicAnimator) {
		self.viewController = viewController
		self.scrollView = scrollView
		self.animator = animator

		super.init()

		scrollView.delegate = self
		
//		let panGesture = UIPanGestureRecognizer(target: self, action: #selector(pan(recognizer:)))
//		panGesture.maximumNumberOfTouches = 1
//		panGesture.delegate = self
//		scrollView.addGestureRecognizer(panGesture)
	}
	
	@objc func pan(recognizer: UIPanGestureRecognizer) {
		guard let viewController = viewController else {
			return
		}
		
		let translation = recognizer.translation(in: viewController.view)
		let distance = hypot(translation.x, translation.y)
		
		switch recognizer.state {
		case .began:
			break
//			for cardView in CardView.all(in: viewController.view) {
//				cardView.snap.snapPoint = cardView.superview!.convert(cardView.center, to: nil)
//
//				cardView.attachment = UIAttachmentBehavior(
//					item: cardView,
//					offsetFromCenter: UIOffset(horizontal: CGFloat.random(in: -10...10), vertical: CGFloat.random(in: -10...10)),
//					attachedToAnchor: cardView.snap.snapPoint)
//
//				animator.addBehavior(cardView.attachment!)
//				animator.addBehavior(cardView.behaviour)
//			}
			
		case .changed:
			
//			for cardView in CardView.all(in: viewController.view) {
//				cardView.attachment?.anchorPoint = CGPoint(x: cardView.snap.snapPoint.x + translation.x, y: cardView.snap.snapPoint.y + translation.y)
//			}
			
			let backgroundPercent = 1 - distance/500
			viewController.view.backgroundColor = UIColor.black.withAlphaComponent(backgroundPercent)
			
			let HUDPercent = 1 - distance/200
			
			for view in viewController.view.allHUDViews() {
				view.alpha = HUDPercent
			}
			
		case .cancelled, .ended, .failed:
			self.animator.removeAllBehaviors()
			
			let velocity = recognizer.velocity(in: viewController.view)
			if distance > 200 || velocity.y > 1000 {
				viewController.dismiss(animated: true, completion: nil)
			} else {
				scrollView.alwaysBounceVertical = true
				scrollView.panGestureRecognizer.isEnabled = true
								
				UIView.animate(withDuration: 0.2) {
					viewController.view.backgroundColor = .black
					for view in viewController.view.allHUDViews() {
						view.alpha = 1.0
					}
				}
				
//				for cardView in CardView.all(in: viewController.view) {
//					animator.addBehavior(cardView.snap)
//					animator.addBehavior(cardView.behaviour)
//				}
				
				self.delegate?.pullToDismissControllerWillCancelPullGesture(self)
			}
		case.possible:
			break
		}
	}
	
}

extension PullToDismissController: UIScrollViewDelegate {
	
	
	
}

extension PullToDismissController: UIGestureRecognizerDelegate {
	
	func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
		animator.removeAllBehaviors()
		
		guard let panGesture = gestureRecognizer as? UIPanGestureRecognizer else {
			return true
		}
		
		let verticality = abs(panGesture.velocity(in: nil).y) / abs(panGesture.velocity(in: nil).x)
		
		if scrollView.contentOffset.y <= -scrollView.adjustedContentInset.top,
			panGesture.velocity(in: nil).y >= 0,
			verticality > 1.0 {
			// Start drag to dismiss gesture
//			scrollView.alwaysBounceVertical = false
//			scrollView.panGestureRecognizer.isEnabled = false
			
			self.delegate?.pullToDismissControllerWillBeginPullGesture(self)
			
			return true
		}
		
		// Scroll as normal
		return false
	}
	
	func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
		return otherGestureRecognizer == scrollView.panGestureRecognizer
	}
	
}
