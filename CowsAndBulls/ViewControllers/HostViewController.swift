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
    
    private let presenter: HostPresenterDelegate?
    
    init(withPresenter presenter: HostPresenter)
    {
        self.presenter = presenter
        
        super.init(nibName: nil, bundle: nil)
        
        presenter.delegate = self
    }
    
    required init?(coder aDecoder: NSCoder)
    {
        self.presenter = nil
        
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
    }
    
    func connectionSuccessful(communicator: CommunicatorHost?, initialData: CommunicatorInitialConnection)
    {
        if let comm = communicator, var viewControllers = navigationController?.viewControllers
        {
            let presenter = GameSetupPresenter(communicator: comm, connectionData: initialData)
            let viewController = GameSetupViewController(withPresenter: presenter)
            
            viewControllers.insert(viewController, at: viewControllers.count)
            
            navigationController?.viewControllers = viewControllers
        }
    }
    
    func connectionFailure(errorMessage: String)
    {
        customView?.stopConnecting()
        
        navigationItem.leftBarButtonItem?.isEnabled = true
        
        let alert = UIAlertController(title: "Error", message: "Failed to start server. Other player cannot join you.", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: {sender -> Void in
            self.navigationController?.popToRootViewController(animated: false)
        }))
        
        navigationController?.present(alert, animated: true, completion: nil)
    }
    
    func timeout()
    {
        customView?.stopConnecting()
        
        navigationItem.leftBarButtonItem?.isEnabled = true
        
        let alert = UIAlertController(title: "Error", message: "Connection timeout. Could not connect with client.", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: { sender -> Void in
            self.presenter?.startHostServer()
        }))
        
        navigationController?.present(alert, animated: true, completion: nil)
    }
}

extension HostViewController : HostActionDelegate
{
    
}
