//
//  CostView.swift
//  X-Squad
//
//  Created by Avario on 08/01/2019.
//  Copyright © 2019 Avario. All rights reserved.
//
// A view used to display point costs.

import Foundation
import UIKit

class CostView: UIView {
	
	var cost: Int = 0 {
		didSet {
			valueLabel.text = String(cost)
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
		
		valueLabel.layer.borderColor = UIColor(named: "XRed")!.withAlphaComponent(0.6).cgColor
		valueLabel.layer.borderWidth = 1
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
