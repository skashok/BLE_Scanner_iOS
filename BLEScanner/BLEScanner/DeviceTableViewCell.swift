//
//  DeviceTableViewCell.swift
//  BLEScanner
//
//  Created by Harry Goodwin on 10/07/2016.
//  Copyright © 2016 GG. All rights reserved.
//

import UIKit

class DeviceTableViewCell: UITableViewCell {

	@IBOutlet weak var deviceNameLabel: UILabel!
	@IBOutlet weak var deviceRssiLabel: UILabel!
	
	var displayPeripheral: DisplayPeripheral? {
		didSet {
			if let deviceName = displayPeripheral!.peripheral?.name{
				deviceNameLabel.text = deviceName.isEmpty ? "No Device Name" : deviceName
			}else{
				deviceNameLabel.text = "No Device Name"
			}
			
			if let rssi = displayPeripheral!.lastRSSI {
				deviceRssiLabel.text = "\(rssi)dB"
			}
			
			if let services = displayPeripheral!.peripheral!.services {
				for service in services {
					if let characteristics = service.characteristics {
						for characteristic in characteristics {
							print(characteristic.descriptors)
						}
					}
				}
			}
		}
	}
}
