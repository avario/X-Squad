//
//  CardCostView.swift
//  X-Squad
//
//  Created by Avario on 08/01/2019.
//  Copyright © 2019 Avario. All rights reserved.
//

import Foundation
import UIKit

class CardCostView: UIView {
	
	var card: Card? {
		didSet {
			valueLabel.text = card?.cost
		}
	}
	
	private let valueLabel = UILabel()
	
	override init(frame: CGRect) {
		super.init(frame: frame)
		
		addSubview(valueLabel)
		valueLabel.translatesAutoresizingMaskIntoConstraints = false
		valueLabel.heightAnchor.constraint(equalToConstant: 24).isActive = true
		valueLabel.widthAnchor.constraint(equalToConstant: 44).isActive = true
		valueLabel.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
		valueLabel.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
		
		valueLabel.layer.cornerRadius = 12
		valueLabel.clipsToBounds = true
		
		valueLabel.layer.borderColor = UIColor(named: "XRed")!.cgColor
		valueLabel.layer.borderWidth = 2
		valueLabel.textColor = UIColor(named: "XRed")
		valueLabel.textAlignment = .center
		valueLabel.font = .kimberley(16)
	}
	
	required init?(coder aDecoder: NSCoder) {
		fatalError()
	}
	
	override var intrinsicContentSize: CGSize {
		return CGSize(width: 44, height: 24)
	}
	
}
