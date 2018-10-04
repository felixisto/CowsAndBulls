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
        
        presenter?.startHostServer()
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
        
        navigationController?.navigationBar.isHidden = false
        navigationItem.title = "Host Game"
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Quit", style: .plain, target: self, action: #selector(actionBack(_:)))
        
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

extension HostViewController
{
    @objc func actionBack(_ sender: Any)
    {
        presenter?.quit()
        
        navigationController?.popViewController(animated: true)
    }
}

extension HostViewController : HostViewDelegate
{
    func connectionBegin()
    {
        customView?.beginConnecting()
        
        navigationItem.leftBarButtonItem?.isEnabled = false
    }
    
    func connectionSuccessful(communicator: CommunicatorHost?)
    {
        navigationItem.leftBarButtonItem?.isEnabled = true
        
        if let comm = communicator
        {
            let presenter = PickRolePresenter(communicator: comm)
            let viewController = PickRoleViewController(withPresenter: presenter)
            
            navigationController?.pushViewController(viewController, animated: true)
        }
    }
    
    func connectionFailure(errorMessage: String)
    {
        customView?.stopConnecting()
        
        navigationItem.leftBarButtonItem?.isEnabled = true
    }
}

extension HostViewController : HostActionDelegate
{
    
}