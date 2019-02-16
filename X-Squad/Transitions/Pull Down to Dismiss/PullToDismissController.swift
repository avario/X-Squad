//
//  PullToDismissController.swift
//  X-Squad
//
//  Created by Avario on 15/01/2019.
//  Copyright © 2019 Avario. All rights reserved.
//
// This manages the "pull to dimiss" gesture used on several screens. It will dimiss the screen if the scroll view is swiped down quickly or pulled down and released past a threshold.

import Foundation
import UIKit

class PullToDismissController: NSObject {
	
	weak var viewController: UIViewController?
	
	init(viewController: UIViewController, scrollView: UIScrollView? = nil) {
		self.viewController = viewController
		
		super.init()

		scrollView?.delegate = self
	}
	
	var potentialDismissDrag = false
	var lockedContentOffset: CGPoint?
}

extension PullToDismissController: UIScrollViewDelegate {
	
	func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
		guard viewController?.isBeingDismissed == false else {
			return
		}
		
		potentialDismissDrag = scrollView.contentOffset.y <= -scrollView.adjustedContentInset.top
	}
	
	func scrollViewDidScroll(_ scrollView: UIScrollView) {
		guard viewController?.isBeingDismissed == false else {
			if let lockedContentOffset = lockedContentOffset {
				scrollView.setContentOffset(lockedContentOffset, animated: false)
			}
			return
		}
		
		let offset = scrollView.contentOffset.y + scrollView.adjustedContentInset.top
		
		let backgroundPercent: CGFloat
		let hudPercent: CGFloat
		if offset < 0 {
			backgroundPercent = 1 - abs(offset)/500
			hudPercent = 1 - abs(offset)/200
		} else {
			backgroundPercent = 1
			hudPercent = 1
		}
		
		viewController!.view.backgroundColor = UIColor.black.withAlphaComponent(backgroundPercent)
		for view in viewController!.view.allHUDViews() {
			view.alpha = hudPercent
		}
	}
	
	func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
		guard viewController?.isBeingDismissed == false else {
			return
		}
		
		if potentialDismissDrag,
			velocity.y < -1 || scrollView.contentOffset.y + scrollView.adjustedContentInset.top < -100 {
			lockedContentOffset = scrollView.contentOffset
			viewController!.dismiss(animated: true, completion: nil)
		}
	}
	
}
