//
//  PeripheralTableViewController.swift
//  BLEScanner
//
//  Created by Harry Goodwin on 21/01/2016.
//  Copyright © 2016 GG. All rights reserved.
//

import CoreBluetooth
import UIKit

struct DisplayPeripheral{
	var peripheral: CBPeripheral?
	var lastRSSI: NSNumber?
	
	init(peripheral: CBPeripheral, lastRSSI: NSNumber){
		self.peripheral = peripheral
		self.lastRSSI = lastRSSI
	}
}

class PeripheralViewController: UIViewController {
	
	@IBOutlet weak var bluetoothIcon: UIImageView!
	@IBOutlet weak var scanninglabel: UILabel!
	
    var centralManager: CBCentralManager?
    var peripherals: [DisplayPeripheral] = []
	
	@IBOutlet weak var tableView: UITableView!
	
	override func viewDidLoad(){
        super.viewDidLoad()
		
		tableView.hidden = true
		//Initialise CoreBluetooth Central Manager
        centralManager = CBCentralManager(delegate: self, queue: dispatch_get_main_queue())
    }
	
	func pulseBluetoothIcon(){
		let scaleAnimation:CABasicAnimation = CABasicAnimation(keyPath: "transform.scale")
		
		scaleAnimation.duration = 0.5
		scaleAnimation.repeatCount = Float.infinity
		scaleAnimation.autoreverses = true
		scaleAnimation.fromValue = 1.1;
		scaleAnimation.toValue = 0.9;
		
		bluetoothIcon.layer.addAnimation(scaleAnimation, forKey: "scale")
		
		let opacityAnimation = CABasicAnimation(keyPath: "opacity")
		opacityAnimation.duration = 0.5
		opacityAnimation.repeatCount = Float.infinity
		opacityAnimation.autoreverses = true
		opacityAnimation.fromValue = 1.0
		opacityAnimation.toValue = 0.2
		
		bluetoothIcon.layer.addAnimation(opacityAnimation, forKey: "opacity")
	}
}

extension PeripheralViewController: CBCentralManagerDelegate{
	func centralManagerDidUpdateState(central: CBCentralManager){
		if (central.state == CBCentralManagerState.PoweredOn){
			self.centralManager?.scanForPeripheralsWithServices(nil, options: nil)
			pulseBluetoothIcon()
		}else{
			// do something like alert the user that ble is not on
		}
	}
	
	func centralManager(central: CBCentralManager, didDiscoverPeripheral peripheral: CBPeripheral, advertisementData: [String : AnyObject], RSSI: NSNumber){
		
		let displayPeripheral = DisplayPeripheral(peripheral: peripheral, lastRSSI: RSSI)
		peripherals.append(displayPeripheral)
		
		if peripherals.count > 0{
			tableView.hidden = false
			tableView.reloadData()
		}
	}
}

extension PeripheralViewController: UITableViewDataSource{
	func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell{
		
		let cell = self.tableView.dequeueReusableCellWithIdentifier("cell")! as! DeviceTableViewCell
		cell.displayPeripheral = peripherals[indexPath.row]
		
		return cell
	}
	
	func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int{
		return peripherals.count
	}
}




