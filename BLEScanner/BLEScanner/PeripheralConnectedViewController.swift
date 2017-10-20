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
	@IBOutlet private weak var tableView: UITableView!
	@IBOutlet private weak var peripheralName: UILabel!
	@IBOutlet private weak var blurView: UIVisualEffectView!
	@IBOutlet private weak var rssiLabel: UILabel!
    @IBOutlet private weak var scanningButton: UIButton!
	
    var peripheral: CBPeripheral?
	private var rssiReloadTimer: Timer?
	private var services: [CBService] = []
	
    override func viewDidLoad() {
        super.viewDidLoad()

        scanningButton.style(with: .btRed)
        
		peripheral?.delegate = self
		peripheralName.text = peripheral?.name
		
		let blurEffect = UIBlurEffect(style: .dark)
		blurView.effect = blurEffect
		
		tableView.rowHeight = UITableViewAutomaticDimension
		tableView.estimatedRowHeight = 80.0
		tableView.contentInset.top = 5
		
		rssiReloadTimer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(PeripheralConnectedViewController.refreshRSSI), userInfo: nil, repeats: true)
	}

	@objc private func refreshRSSI(){
		peripheral?.readRSSI()
	}

	@IBAction private func disconnectButtonPressed(_ sender: AnyObject) {
		UIView.animate(withDuration: 0.5, animations: {
			self.view.alpha = 0.0
			}, completion: {_ in
				self.dismiss(animated: false, completion: nil)
		}) 
	}
}

extension PeripheralConnectedViewController: UITableViewDataSource{
	
	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return services.count
	}
	
	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let cell = tableView.dequeueReusableCell(withIdentifier: "ServiceCell") as! ServiceTableViewCell
		cell.serviceNameLabel.text = "\(services[indexPath.row].uuid)"
		
		return cell
	}
}

extension PeripheralConnectedViewController: CBPeripheralDelegate {
	func centralManager(_ central: CBCentralManager, didFailToConnectPeripheral peripheral: CBPeripheral, error: NSError?) {
        if let error = error {
            print("Error connecting peripheral: \(error.localizedDescription)")
        }
	}

	func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
		if let error = error {
			print("Error discovering services: \(error.localizedDescription)")
		}
		
		peripheral.services?.forEach({ (service) in
			services.append(service)
			tableView.reloadData()
			peripheral.discoverCharacteristics(nil, for: service)
		})
	}
	
	func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
		if let error = error {
			print("Error discovering service characteristics: \(error.localizedDescription)")
		}
		
		service.characteristics?.forEach({ characteristic in
            if let descriptors = characteristic.descriptors {
                print(descriptors)
            }
            
			print(characteristic.properties)
		})
	}
	
	func peripheral(_ peripheral: CBPeripheral, didReadRSSI RSSI: NSNumber, error: Error?) {
		switch RSSI.intValue {
		case -90 ... -60:
			rssiLabel.textColor = .btOrange
			break
		case -200 ... -90:
			rssiLabel.textColor = .btRed
			break
		default:
			rssiLabel.textColor = .btGreen
		}
		
		rssiLabel.text = "\(RSSI)dB"
	}
}
