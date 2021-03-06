//
//  JoinViewController.swift
//  CowsAndBulls
//
//  Created by Kristiyan Butev on 2.10.18.
//  Copyright © 2018 Kristiyan Butev. All rights reserved.
//

import UIKit

let ClientLastHostAddressKey = "ClientLastHostAddressKey"

class ClientViewController: UIViewController
{
    private var customView: ClientView?
    
    private let presenter: ClientPresenterDelegate?
    
    init(withPresenter presenter: ClientPresenter)
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
        self.customView = self.view as? ClientView
        self.customView?.delegate = self
        
        navigationController?.navigationBar.isHidden = false
        navigationItem.title = "Join Game"
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Quit", style: .plain, target: self, action: #selector(actionBack(_:)))
        
        if let lastHostAddress = UserDefaults.standard.string(forKey: ClientLastHostAddressKey)
        {
            if lastHostAddress.count > 0
            {
                self.customView?.setHostAddress(text: lastHostAddress)
            }
        }
    }
}

extension ClientViewController
{
    @objc func actionBack(_ sender: Any)
    {
        presenter?.quit()
        
        navigationController?.popViewController(animated: true)
    }
}

extension ClientViewController : ClientViewDelegate
{
    func connectionBegin()
    {
        customView?.foundConnection()
        
        navigationItem.leftBarButtonItem?.isEnabled = false
    }
    
    func connectionSuccessful(communicator: CommunicatorClient?, initialData: CommunicatorInitialConnection)
    {
        navigationItem.leftBarButtonItem?.isEnabled = true
        
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
        
        let alert = UIAlertController(title: "Error", message: "Could not find host server.", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
        
        navigationController?.present(alert, animated: true, completion: nil)
    }
    
    func timeout()
    {
        customView?.stopConnecting()
        
        navigationItem.leftBarButtonItem?.isEnabled = true
        
        let alert = UIAlertController(title: "Error", message: "Connection timeout. Could not connect with server.", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
        
        navigationController?.present(alert, animated: true, completion: nil)
    }
}

extension ClientViewController : ClientActionDelegate
{
    func connect(hostAddress: String)
    {
        customView?.beginConnecting()
        presenter?.connect(hostAddress: hostAddress)
        
        // Save the address, it will be used as default address next time the CLIENT screen starts
        UserDefaults.standard.set(hostAddress, forKey: ClientLastHostAddressKey)
    }
}
