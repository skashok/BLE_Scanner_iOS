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
	var viewReloadTimer: Timer?
	
	var selectedPeripheral: CBPeripheral?
	
	@IBOutlet weak var tableView: UITableView!
	
	required init?(coder aDecoder: NSCoder) {
		super.init(coder: aDecoder)
		
		//Initialise CoreBluetooth Central Manager
		centralManager = CBCentralManager(delegate: self, queue: DispatchQueue.main)
	}
	
	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
		
		viewReloadTimer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(PeripheralViewController.refreshScanView), userInfo: nil, repeats: true)
	}
	
	override func viewWillDisappear(_ animated: Bool) {
		super.viewWillDisappear(animated)
		
		viewReloadTimer?.invalidate()
	}
	
	func updateViewForScanning(){
		statusLabel.text = "Scanning BLE Devices..."
		bluetoothIcon.pulseAnimation()
		bluetoothIcon.isHidden = false
		scanningButton.buttonColorScheme(true)
	}
	
	func updateViewForStopScanning(){
		let plural = peripherals.count > 1 ? "s" : ""
		statusLabel.text = "\(peripherals.count) Device\(plural) Found"
		bluetoothIcon.layer.removeAllAnimations()
		bluetoothIcon.isHidden = true
		scanningButton.buttonColorScheme(false)
	}
	
	@IBAction func scanningButtonPressed(_ sender: AnyObject){
		if centralManager!.isScanning{
			centralManager?.stopScan()
			updateViewForStopScanning()
		}else{
			startScanning()
		}
	}
	
	func startScanning(){
		peripherals = []
		self.centralManager?.scanForPeripherals(withServices: nil, options: [CBCentralManagerScanOptionAllowDuplicatesKey: true])
		updateViewForScanning()
		let triggerTime = (Int64(NSEC_PER_SEC) * 10)
		DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + Double(triggerTime) / Double(NSEC_PER_SEC), execute: { () -> Void in
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
	
	override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
		if let destinationViewController = segue.destination as? PeripheralConnectedViewController{
			destinationViewController.peripheral = selectedPeripheral
		}
	}
}

extension PeripheralViewController: CBCentralManagerDelegate{
	func centralManagerDidUpdateState(_ central: CBCentralManager){
		if (central.state == .poweredOn){
			startScanning()
		}else{
			// do something like alert the user that ble is not on
		}
	}
	
	func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber){
		
		for (index, foundPeripheral) in peripherals.enumerated(){
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
	func centralManager(_ central: CBCentralManager, didFailToConnect peripheral: CBPeripheral, error: Error?) {
		print("Error connecting peripheral: \(error?.localizedDescription)")
	}
	
	func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
		print("Peripheral connected")
		performSegue(withIdentifier: "PeripheralConnectedSegue", sender: self)
		peripheral.discoverServices(nil)
	}
}

extension PeripheralViewController: UITableViewDataSource {
	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell{
		
		let cell = self.tableView.dequeueReusableCell(withIdentifier: "cell")! as! DeviceTableViewCell
		cell.displayPeripheral = peripherals[indexPath.row]
		cell.delegate = self
		return cell
	}
	
	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int{
		return peripherals.count
	}
}

extension PeripheralViewController: DeviceCellDelegate{
	func connectPressed(_ peripheral: CBPeripheral) {
		if peripheral.state != .connected {
			selectedPeripheral = peripheral
			peripheral.delegate = self
			centralManager?.connect(peripheral, options: nil)
		}
	}
}

