//
//  DialButton.swift
//  X-Squad
//
//  Created by Avario on 31/01/2019.
//  Copyright © 2019 Avario. All rights reserved.
//

import Foundation
import UIKit

class DialButton: UIButton {
	
	private let dialImageView = UIImageView(image: UIImage(named: "Dial")!)
	
	private let color = UIColor.white.withAlphaComponent(0.5)
	private let highlightColor = UIColor.white
	
	init() {
		super.init(frame: .zero)
		
		translatesAutoresizingMaskIntoConstraints = false
		
		addSubview(dialImageView)
		dialImageView.translatesAutoresizingMaskIntoConstraints = false
		dialImageView.contentMode = .scaleAspectFit
		dialImageView.heightAnchor.constraint(equalToConstant: 24).isActive = true
		dialImageView.widthAnchor.constraint(equalToConstant: 24).isActive = true
		dialImageView.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
		dialImageView.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
		
		dialImageView.tintColor = color
	}
	
	required init?(coder aDecoder: NSCoder) {
		fatalError()
	}
	
	override open var isHighlighted: Bool {
		didSet {
			dialImageView.tintColor = isHighlighted ? highlightColor : color
		}
	}
	
	override var intrinsicContentSize: CGSize {
		return CGSize(width: 44, height: 44)
	}
}
