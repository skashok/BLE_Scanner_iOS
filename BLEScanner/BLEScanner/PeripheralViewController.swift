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
	var isConnectable: Bool?
}

class PeripheralViewController: UIViewController {
	
	@IBOutlet weak var statusLabel: UILabel!
	@IBOutlet weak var bluetoothIcon: UIImageView!
	@IBOutlet weak var scanningButton: ScanButton!
	
    var centralManager: CBCentralManager?
    var peripherals: [DisplayPeripheral] = []
	var viewReloadTimer: NSTimer?
	
	var selectedPeripheral: CBPeripheral?
	
	@IBOutlet weak var tableView: UITableView!
	
	required init?(coder aDecoder: NSCoder) {
		super.init(coder: aDecoder)
		
		//Initialise CoreBluetooth Central Manager
		centralManager = CBCentralManager(delegate: self, queue: dispatch_get_main_queue())
	}
	
	override func viewWillAppear(animated: Bool) {
		super.viewWillAppear(animated)
		
		viewReloadTimer = NSTimer.scheduledTimerWithTimeInterval(1.0, target: self, selector: #selector(PeripheralViewController.refreshScanView), userInfo: nil, repeats: true)
	}
	
	override func viewWillDisappear(animated: Bool) {
		super.viewWillDisappear(animated)
		
		viewReloadTimer?.invalidate()
	}
	
	func updateViewForScanning(){
		statusLabel.text = "Scanning BLE Devices..."
		bluetoothIcon.pulseAnimation()
		bluetoothIcon.hidden = false
		scanningButton.buttonColorScheme(true)
	}
	
	func updateViewForStopScanning(){
		let plural = peripherals.count > 1 ? "s" : ""
		statusLabel.text = "\(peripherals.count) Device\(plural) Found"
		bluetoothIcon.layer.removeAllAnimations()
		bluetoothIcon.hidden = true
		scanningButton.buttonColorScheme(false)
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
	
	override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
		if let destinationViewController = segue.destinationViewController as? PeripheralConnectedViewController{
			destinationViewController.peripheral = selectedPeripheral
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
		
		for (index, foundPeripheral) in peripherals.enumerate(){
			if foundPeripheral.peripheral?.identifier == peripheral.identifier{
				peripherals[index].lastRSSI = RSSI
				return
			}
		}
		
		let isConnectable = advertisementData["kCBAdvDataIsConnectable"] as! Bool
		let displayPeripheral = DisplayPeripheral(peripheral: peripheral, lastRSSI: RSSI, isConnectable: isConnectable)
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
		performSegueWithIdentifier("PeripheralConnectedSegue", sender: self)
		peripheral.discoverServices(nil)
	}
}

extension PeripheralViewController: UITableViewDataSource {
	func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell{
		
		let cell = self.tableView.dequeueReusableCellWithIdentifier("cell")! as! DeviceTableViewCell
		cell.displayPeripheral = peripherals[indexPath.row]
		cell.delegate = self
		return cell
	}
	
	func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int{
		return peripherals.count
	}
}

extension PeripheralViewController: DeviceCellDelegate{
	func connectPressed(peripheral: CBPeripheral) {
		if peripheral.state != .Connected {
			selectedPeripheral = peripheral
			peripheral.delegate = self
			centralManager?.connectPeripheral(peripheral, options: nil)
		}
	}
}

