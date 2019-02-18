//
//  CardViewController.swift
//  X-Squad
//
//  Created by Avario on 03/01/2019.
//  Copyright © 2019 Avario. All rights reserved.
//
// This screen displays a single card enlarged to fill the screen width, with its point cost (and upgrade slots for pilot cards).

import Foundation
import UIKit

protocol CardViewControllerDelegate: AnyObject {
	func squadActionForCardViewController(_ cardViewController: CardViewController) -> SquadButton.Action?
	func cardViewControllerDidPressSquadButton(_ cardViewController: CardViewController)
}

class CardViewController: UIViewController {
	
	let card: Card
	
	// The member is needed so that the current point cost can be shown (for upgrades that have variable costs).
	let member: Squad.Member?
	
	let cardView = CardView()
	
	weak var delegate: CardViewControllerDelegate?
	
	private lazy var animator: UIDynamicAnimator = UIDynamicAnimator(referenceView: view)
	private var attach: UIAttachmentBehavior?
	
	// This is the button that is used to modify a squad ("Add to Squad", "Remove from Pilot", etc).
	let squadButton = SquadButton()
	
	let closeButton = CloseButton()
	
	init(card: Card, member: Squad.Member? = nil) {
		self.card = card
		self.member = member
		
		super.init(nibName: nil, bundle: nil)
		
		transitioningDelegate = self
		modalPresentationStyle = .overCurrentContext
	}
	
	required init?(coder aDecoder: NSCoder) {
		fatalError()
	}
	
	override var preferredStatusBarStyle: UIStatusBarStyle {
		return .lightContent
	}
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		navigationController?.navigationBar.barStyle = .black
		view.backgroundColor = UIColor(named: "XBackground")
		
		view.addSubview(cardView)
		let cardWidth = view.frame.width - 20
		cardView.frame = CGRect(origin: .zero, size: CGSize(width: cardWidth, height: cardWidth * CardView.heightMultiplier(for: card)))
		cardView.center = CGPoint(x: view.center.x, y: view.center.y - 20)
		
		cardView.card = card
		cardView.snap.snapPoint = cardView.center
		
		// Used to drag the card around.
		let panGesture = UIPanGestureRecognizer(target: self, action: #selector(panCard(recognizer:)))
		panGesture.maximumNumberOfTouches = 1
		cardView.addGestureRecognizer(panGesture)
		cardView.isUserInteractionEnabled = true
		
		// Layout guide for the card's resting position.
		let cardLayoutGuide = UILayoutGuide()
		view.addLayoutGuide(cardLayoutGuide)
		cardLayoutGuide.topAnchor.constraint(equalTo: view.topAnchor, constant: cardView.frame.minY).isActive = true
		cardLayoutGuide.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -(view.frame.height - cardView.frame.maxY)).isActive = true
		cardLayoutGuide.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -10).isActive = true
		cardLayoutGuide.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 10).isActive = true
		
		// Squad button
		if let action = delegate?.squadActionForCardViewController(self) {
			view.insertSubview(squadButton, belowSubview: cardView)
			squadButton.action = action
			squadButton.addTarget(self, action: #selector(squadButtonPressed), for: .touchUpInside)
			
			squadButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -24).isActive = true
			squadButton.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
		}
		
		if card.isReleased {
			// Cost view
			let costView = CostView()
			view.insertSubview(costView, belowSubview: cardView)
			costView.translatesAutoresizingMaskIntoConstraints = false
			
			costView.topAnchor.constraint(equalTo: cardLayoutGuide.bottomAnchor, constant: 15).isActive = true
			costView.rightAnchor.constraint(equalTo: cardLayoutGuide.rightAnchor, constant: -10).isActive = true
			
			costView.cost = card.pointCost(for: member)
			
			// Hyperspace label
			let hyperspaceLabel = UILabel()
			hyperspaceLabel.textColor = UIColor.white.withAlphaComponent(0.5)
			hyperspaceLabel.font = UIFont.systemFont(ofSize: 12)
			hyperspaceLabel.text = "H"
			hyperspaceLabel.translatesAutoresizingMaskIntoConstraints = false
			hyperspaceLabel.isHidden = card.hyperspace == false
			
			view.insertSubview(hyperspaceLabel, belowSubview: cardView)
			hyperspaceLabel.rightAnchor.constraint(equalTo: cardLayoutGuide.rightAnchor, constant: -10).isActive = true
			
			if let pilot = card as? Pilot {
				// Dial
				let ship = DataStore.ships.first(where: { $0.pilots.contains(pilot) })!
				let dialView = DialView(ship: ship)
				
				view.insertSubview(dialView, belowSubview: cardView)
				
				dialView.bottomAnchor.constraint(equalTo: cardLayoutGuide.bottomAnchor).isActive = true
				dialView.leftAnchor.constraint(equalTo: cardLayoutGuide.leftAnchor, constant: 10).isActive = true
				
				// Ship size
				let shipSizeLabel = UILabel()
				shipSizeLabel.textAlignment = .center
				shipSizeLabel.textColor = UIColor.white.withAlphaComponent(0.5)
				shipSizeLabel.font = UIFont.xWingIcon(24)
				shipSizeLabel.text = ship.size.characterCode
				shipSizeLabel.translatesAutoresizingMaskIntoConstraints = false
				
				view.insertSubview(shipSizeLabel, belowSubview: cardView)
				shipSizeLabel.bottomAnchor.constraint(equalTo: cardLayoutGuide.bottomAnchor, constant: -10).isActive = true
				shipSizeLabel.rightAnchor.constraint(equalTo: cardLayoutGuide.rightAnchor, constant: -10).isActive = true
				
				// Hyperspace
				hyperspaceLabel.bottomAnchor.constraint(equalTo: shipSizeLabel.topAnchor,  constant: -10).isActive = true
				
				// Upgrades
				let upgradeBar = UIStackView()
				upgradeBar.translatesAutoresizingMaskIntoConstraints = false
				upgradeBar.axis = .horizontal
				view.insertSubview(upgradeBar, belowSubview: cardView)
				
				upgradeBar.topAnchor.constraint(equalTo: cardLayoutGuide.bottomAnchor, constant: 15).isActive = true
				upgradeBar.leftAnchor.constraint(equalTo: cardLayoutGuide.leftAnchor, constant: 10).isActive = true
				
				for upgrade in pilot.slots ?? [] {
					let upgradeButton = UpgradeButton()
					upgradeButton.isUserInteractionEnabled = false
					upgradeButton.upgradeType = upgrade
					
					upgradeBar.addArrangedSubview(upgradeButton)
				}
			} else {
				// Hyperspace
				hyperspaceLabel.bottomAnchor.constraint(equalTo: cardLayoutGuide.bottomAnchor,  constant: -10).isActive = true
			}
		} else {
			let unreleasedLabel = UILabel()
			unreleasedLabel.textColor = UIColor.white.withAlphaComponent(0.5)
			unreleasedLabel.text = "Unreleased"
			
			view.insertSubview(unreleasedLabel, belowSubview: cardView)
			unreleasedLabel.translatesAutoresizingMaskIntoConstraints = false
			
			unreleasedLabel.topAnchor.constraint(equalTo: cardLayoutGuide.bottomAnchor, constant: 15).isActive = true
			unreleasedLabel.rightAnchor.constraint(equalTo: cardLayoutGuide.rightAnchor, constant: -10).isActive = true
		}
		
		// Close button
		closeButton.translatesAutoresizingMaskIntoConstraints = false
		
		view.addSubview(closeButton)
		closeButton.rightAnchor.constraint(equalTo: view.safeAreaLayoutGuide.rightAnchor, constant: -20).isActive = true
		closeButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor).isActive = true
		
		closeButton.addTarget(self, action: #selector(close), for: .touchUpInside)
	}
	
	@objc func close() {
		dismiss(animated: true, completion: nil)
	}
	
	@objc func squadButtonPressed() {
		delegate?.cardViewControllerDidPressSquadButton(self)
	}
	
	@objc func panCard(recognizer: UIPanGestureRecognizer) {
		let distance = cardView.center.y - view.center.y
		
		switch recognizer.state {
		case .began:
			animator.removeBehavior(cardView.snap)
			
			let locationInCard = recognizer.location(in: cardView)
			let offsetFromCenterInCard = UIOffset(
				horizontal: locationInCard.x - cardView.bounds.midX,
				vertical: locationInCard.y - cardView.bounds.midY)
			
			let locationInView = recognizer.location(in: view)
			
			attach = UIAttachmentBehavior(
				item: cardView,
				offsetFromCenter: offsetFromCenterInCard,
				attachedToAnchor: locationInView)
			
			animator.addBehavior(attach!)
			animator.addBehavior(cardView.behaviour)
			
		case .changed:
			let anchor = recognizer.location(in: view)
			attach?.anchorPoint = anchor
			
			let backgroundPercent = 1 - distance/500
			view.backgroundColor = UIColor(named: "XBackground")!.withAlphaComponent(backgroundPercent)

			let HUDPercent = 1 - distance/200
			for hudView in view.allHUDViews() {
				hudView.alpha = HUDPercent
			}
			
		case .cancelled, .ended, .failed:
			if let attach = attach {
				animator.removeBehavior(attach)
			}
			attach = nil
			
			let velocity = recognizer.velocity(in: view)
			let velocityLength = hypot(velocity.x, velocity.y)
			
			if distance > 200 || velocityLength > 1000 {
				// Dismisses the view if the card has been swiped down.
				dismiss(animated: true, completion: nil)
			} else {
				animator.addBehavior(cardView.snap)
				animator.addBehavior(cardView.behaviour)
				
				UIView.animate(withDuration: 0.2) {
					self.view.backgroundColor = UIColor(named: "XBackground")
					for hudView in self.view.allHUDViews() {
						hudView.alpha = 1.0
					}
				}
			}
		case.possible:
			break
		}
	}
	
	var dismissTargetViewController: UIViewController?
}

extension CardViewController: UIViewControllerTransitioningDelegate {
	
	func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
		return CardsPresentAnimationController()
	}
	
	func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
		return CardsDismissAnimationController(targetViewController: dismissTargetViewController)
	}

}
