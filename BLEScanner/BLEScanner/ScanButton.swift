//
//  ScanButton.swift
//  BLEScanner
//
//  Created by Harry Goodwin on 18/07/2016.
//  Copyright © 2016 GG. All rights reserved.
//

import UIKit

class ScanButton: UIButton {
	
	required init?(coder aDecoder: NSCoder){
		super.init(coder: aDecoder)
		
		layer.borderWidth = 1.5
		layer.borderColor = UIColor.bluetoothBlueColor().CGColor
	}
	
	func buttonColorScheme(isScanning: Bool){
		let title = isScanning ? "Stop Scanning" : "Start Scanning"
		setTitle(title, forState: .Normal)
		
		let titleColor = isScanning ? UIColor.bluetoothBlueColor() : UIColor.whiteColor()
		setTitleColor(titleColor, forState: .Normal)

		backgroundColor = isScanning ? UIColor.clearColor() : UIColor.bluetoothBlueColor()
	}
}
