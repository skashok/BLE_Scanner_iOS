//
//  PeripheralConnectedViewController.swift
//  BLEScanner
//
//  Created by Harry Goodwin on 18/07/2016.
//  Copyright © 2016 GG. All rights reserved.
//

import UIKit
import CoreBluetooth

class PeripheralConnectedViewController: UIViewController {

	@IBOutlet weak var tableView: UITableView!
	var peripheral: CBPeripheral?
	@IBOutlet weak var peripheralName: UILabel!
	@IBOutlet weak var blurView: UIVisualEffectView!
	
	var services: [CBService] = []
	
    override func viewDidLoad() {
        super.viewDidLoad()

		peripheral?.delegate = self
		peripheralName.text = peripheral?.name
		
		let blurEffect = UIBlurEffect(style: .Dark)
		blurView.effect = blurEffect
		
		tableView.rowHeight = UITableViewAutomaticDimension
		tableView.estimatedRowHeight = 80.0
		tableView.contentInset.top = 10
	}

	@IBAction func disconnectButtonPressed(sender: AnyObject) {
		UIView.animateWithDuration(0.5, animations: {
			self.view.alpha = 0.0
			}) {_ in
				self.dismissViewControllerAnimated(false, completion: nil)
		}
	}
}

extension PeripheralConnectedViewController: UITableViewDataSource{
	
	func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return services.count
	}
	
	func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
		let cell = tableView.dequeueReusableCellWithIdentifier("ServiceCell") as! ServiceTableViewCell
		cell.serviceNameLabel.text = "\(services[indexPath.row].UUID)"
		
		return cell
	}
}

extension PeripheralConnectedViewController: CBPeripheralDelegate {
	func centralManager(central: CBCentralManager, didFailToConnectPeripheral peripheral: CBPeripheral, error: NSError?) {
		print("Error connecting peripheral: \(error?.localizedDescription)")
	}

	func peripheral(peripheral: CBPeripheral, didDiscoverServices error: NSError?) {
		if error != nil {
			print("Error discovering services: \(error?.localizedDescription)")
		}
		
		peripheral.services?.forEach({ (service) in
			print(service)
			services.append(service)
			tableView.reloadData()
			//peripheral.discoverCharacteristics(nil, forService: service)
		})
	}
	
	func peripheral(peripheral: CBPeripheral, didDiscoverCharacteristicsForService service: CBService, error: NSError?) {
		if error != nil {
			print("Error discovering service characteristics: \(error?.localizedDescription)")
		}
		
		//print(service.characteristics)
	}
}
