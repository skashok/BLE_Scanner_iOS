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
	
	@IBOutlet weak var statusLabel: UILabel!
	@IBOutlet weak var bluetoothIcon: UIImageView!
	@IBOutlet weak var scanningButton: UIButton!
	
    var centralManager: CBCentralManager?
    var peripherals: [DisplayPeripheral] = []
	
	@IBOutlet weak var tableView: UITableView!
	
	
	override func viewDidLoad(){
        super.viewDidLoad()
		
		//Initialise CoreBluetooth Central Manager
        centralManager = CBCentralManager(delegate: self, queue: dispatch_get_main_queue())
		
		var viewReloadTimer = NSTimer.scheduledTimerWithTimeInterval(2.0, target: self, selector: Selector("refreshScanView"), userInfo: nil, repeats: true)
    }
	
	func updateViewForScanning(){
		statusLabel.text = "Scanning BLE Devices..."
		bluetoothIcon.pulseAnimation()
		bluetoothIcon.hidden = false
		scanningButton.setTitle("Stop Scanning", forState: .Normal)
		scanningButton.setTitleColor(UIColor.bluetoothBlueColor(), forState: .Normal)
		scanningButton.layer.borderColor = UIColor.bluetoothBlueColor().CGColor
		scanningButton.layer.borderWidth = 1.5
		scanningButton.backgroundColor = UIColor.clearColor()
		
	}
	
	func updateViewForStopScanning(){
		let plural = peripherals.count > 1 ? "s" : ""
		statusLabel.text = "\(peripherals.count) Device\(plural) Found"
		bluetoothIcon.layer.removeAllAnimations()
		bluetoothIcon.hidden = true
		scanningButton.setTitle("Start Scanning", forState: .Normal)
		scanningButton.setTitleColor(UIColor.whiteColor(), forState: .Normal)
		scanningButton.layer.borderColor = UIColor.bluetoothBlueColor().CGColor
		scanningButton.backgroundColor = UIColor.bluetoothBlueColor()
	}
	
	@IBAction func scanningButtonPressed(sender: AnyObject){
		if centralManager!.isScanning{
			centralManager?.stopScan()
			updateViewForStopScanning()
		}else{
			startScanning()
		}
	}
	
	func startScanning(){
		peripherals = []
		self.centralManager?.scanForPeripheralsWithServices(nil, options: [CBCentralManagerScanOptionAllowDuplicatesKey: true])
		updateViewForScanning()
		let triggerTime = (Int64(NSEC_PER_SEC) * 10)
		dispatch_after(dispatch_time(DISPATCH_TIME_NOW, triggerTime), dispatch_get_main_queue(), { () -> Void in
			if self.centralManager!.isScanning{
				self.centralManager?.stopScan()
				self.updateViewForStopScanning()
			}
		})
	}
	
	func refreshScanView()
	{
		if peripherals.count > 1 && centralManager!.isScanning{
			tableView.reloadData()
		}
	}
}

extension PeripheralViewController: CBCentralManagerDelegate{
	func centralManagerDidUpdateState(central: CBCentralManager){
		if (central.state == CBCentralManagerState.PoweredOn){
			startScanning()
		}else{
			// do something like alert the user that ble is not on
		}
	}
	
	func centralManager(central: CBCentralManager, didDiscoverPeripheral peripheral: CBPeripheral, advertisementData: [String : AnyObject], RSSI: NSNumber){
//		
//		for (key, value) in advertisementData {
//			print("\(peripheral.name): \(key) -> \(value)")
//		}
//		
//		if peripheral.state != .Connected {
//			peripheral.delegate = self
//			//centralManager?.connectPeripheral(peripheral, options: nil)
//		}
		
		for (index, foundPeripheral) in peripherals.enumerate(){
			if foundPeripheral.peripheral?.identifier == peripheral.identifier{
				peripherals[index].lastRSSI = RSSI
				return
			}
		}
		
		let displayPeripheral = DisplayPeripheral(peripheral: peripheral, lastRSSI: RSSI)
		peripherals.append(displayPeripheral)
		tableView.reloadData()
	}
}

extension PeripheralViewController: CBPeripheralDelegate {
	func centralManager(central: CBCentralManager, didFailToConnectPeripheral peripheral: CBPeripheral, error: NSError?) {
		print("Error connecting peripheral: \(error?.localizedDescription)")
	}
	
	func centralManager(central: CBCentralManager, didConnectPeripheral peripheral: CBPeripheral) {
		print("Peripheral connected")
		peripheral.discoverServices(nil)
	}
	
	func peripheral(peripheral: CBPeripheral, didDiscoverServices error: NSError?) {
		if error != nil {
			print("Error discovering services: \(error?.localizedDescription)")
		}
		
		peripheral.services?.forEach({ (service) in
			print(service)
			peripheral.discoverCharacteristics(nil, forService: service)
		})
	}
	
	func peripheral(peripheral: CBPeripheral, didDiscoverCharacteristicsForService service: CBService, error: NSError?) {
		if error != nil {
			print("Error discovering service characteristics: \(error?.localizedDescription)")
		}
		
		//print(service.characteristics)
	}
}

extension PeripheralViewController: UITableViewDataSource {
	func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell{
		
		let cell = self.tableView.dequeueReusableCellWithIdentifier("cell")! as! DeviceTableViewCell
		cell.displayPeripheral = peripherals[indexPath.row]
		
		return cell
	}
	
	func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int{
		return peripherals.count
	}
}


