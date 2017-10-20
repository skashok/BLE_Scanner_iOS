//
//  DeviceTableViewCell.swift
//  BLEScanner
//
//  Created by Harry Goodwin on 10/07/2016.
//  Copyright © 2016 GG. All rights reserved.
//

import UIKit
import CoreBluetooth

private struct Constants {
    static let noDeviceName = "No Device Name"
}

protocol DeviceCellDelegate: class {
	func connectPressed(_ peripheral: CBPeripheral)
}

class DeviceTableViewCell: UITableViewCell {
	@IBOutlet weak var deviceNameLabel: UILabel!
	@IBOutlet weak var deviceRssiLabel: UILabel!
	@IBOutlet weak var connectButton: UIButton!
	
	var delegate: DeviceCellDelegate?
	
	var displayPeripheral: DisplayPeripheral? {
		didSet {
			if let deviceName = displayPeripheral?.peripheral?.name, !deviceName.isEmpty {
				deviceNameLabel.text = deviceName
			}else{
				deviceNameLabel.text = Constants.noDeviceName
			}
			
			if let rssi = displayPeripheral!.lastRSSI {
				deviceRssiLabel.text = "\(rssi)dB"
			}
			
            let deviceIsConnectable = displayPeripheral?.isConnectable ?? false
			connectButton.isHidden = !deviceIsConnectable
		}
	}
	
	@IBAction func connectButtonPressed(_ sender: AnyObject) {
		delegate?.connectPressed((displayPeripheral?.peripheral)!)
	}
}
