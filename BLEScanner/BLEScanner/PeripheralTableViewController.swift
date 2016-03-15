//
//  PeripheralTableViewController.swift
//  BLEScanner
//
//  Created by Harry Goodwin on 21/01/2016.
//  Copyright © 2016 GG. All rights reserved.
//

import CoreBluetooth
import UIKit

class PeripheralTableViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, CBCentralManagerDelegate
{
    var centralManager: CBCentralManager?
    var peripherals: Array<CBPeripheral> = Array<CBPeripheral>()
	
	@IBOutlet weak var tableView: UITableView!
	
	override func viewDidLoad()
    {
        super.viewDidLoad()
		
		//Initialise CoreBluetooth Central Manager
        centralManager = CBCentralManager(delegate: self, queue: dispatch_get_main_queue())
    }
	

	//CoreBluetooth methods
    func centralManagerDidUpdateState(central: CBCentralManager)
    {
        if (central.state == CBCentralManagerState.PoweredOn)
        {
            self.centralManager?.scanForPeripheralsWithServices(nil, options: nil)
        }
        else
        {
            // do something like alert the user that ble is not on
        }
    }

    func centralManager(central: CBCentralManager, didDiscoverPeripheral peripheral: CBPeripheral, advertisementData: [String : AnyObject], RSSI: NSNumber)
    {
        peripherals.append(peripheral)
		tableView.reloadData()
    }
	

	//UITableView methods
	func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell
    {
        let cell:UITableViewCell = self.tableView.dequeueReusableCellWithIdentifier("cell")! as UITableViewCell
		
		let peripheral = peripherals[indexPath.row]
		let serviceString = peripheral.name == "" ? "No device name" : peripheral.name
		
		cell.textLabel?.text = serviceString
		
        return cell
    }

    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        return peripherals.count
    }
}
