//
//  ViewController.swift
//  CowsAndBulls
//
//  Created by Kristiyan Butev on 2.10.18.
//  Copyright © 2018 Kristiyan Butev. All rights reserved.
//

import UIKit

class HostViewController: UIViewController
{
    private var customView: HostView?
    
    private var presenter: HostPresenterDelegate? = nil
    
    init(withPresenter presenter: HostPresenter)
    {
        super.init(nibName: nil, bundle: nil)
        
        self.presenter = presenter
        presenter.delegate = self
    }
    
    required init?(coder aDecoder: NSCoder)
    {
        super.init(coder: aDecoder)
    }
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        initInterface()
        
        presenter?.hostBegin()
    }
    
    override func viewWillAppear(_ animated: Bool)
    {
        super.viewWillAppear(animated)
    }
    
    override func didReceiveMemoryWarning()
    {
        super.didReceiveMemoryWarning()
    }
    
    private func initInterface()
    {
        self.customView = self.view as? HostView
        self.customView?.delegate = self
        
        navigationItem.title = "Host game"
        
        if let localIPAddress = LocalIPAddress.get()
        {
            self.customView?.setYourIP(address: localIPAddress)
        }
        else
        {
            let alert = UIAlertController(title: "Network Error", message: "Could retrieve your IP address!", preferredStyle: .alert)
            
            alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
        }
    }
}

extension HostViewController : HostViewDelegate
{
    func connectionSuccessful(communicator: Communicator?)
    {
        navigationController?.pushViewController(PickRoleViewController(withPresenter: PickRolePresenter()), animated: true)
    }
    
    func connectionFailure(errorMessage: String)
    {
        
    }
}

extension HostViewController : HostActionDelegate
{
    
}
