//
//  LoadingViewController.swift
//  BLEScanner
//
//  Created by HARRY G GOODWIN on 22/10/2017.
//  Copyright © 2017 GG. All rights reserved.
//

import UIKit

protocol ConnectingViewControllerDelegate: class {
    func didTapCancel(_ vc: ConnectingViewController)
}

class ConnectingViewController: UIViewController {
    @IBOutlet weak var loadingOverlayView: UIView!
    @IBOutlet weak var cancelButton: UIButton!
    
    weak var delegate: ConnectingViewControllerDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        loadingOverlayView.layer.cornerRadius = 3
        cancelButton.layer.cornerRadius = 3
    }
    
    @IBAction func didTapCancelButton(_ sender: Any) {
        delegate?.didTapCancel(self)
    }
}
