//
//  JoinViewController.swift
//  CowsAndBulls
//
//  Created by Kristiyan Butev on 2.10.18.
//  Copyright © 2018 Kristiyan Butev. All rights reserved.
//

import UIKit

class ClientViewController: UIViewController
{
    private var customView: ClientView?
    
    private var presenter: ClientPresenterDelegate? = nil
    
    init(withPresenter presenter: ClientPresenter)
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
        
        if let comm = communicator
        {
            let presenter = GameSetupPresenter(communicator: comm, connectionData: initialData)
            let viewController = GameSetupViewController(withPresenter: presenter)
            
            navigationController?.pushViewController(viewController, animated: true)
        }
    }
    
    func connectionFailure(errorMessage: String)
    {
        customView?.stopConnecting()
        
        navigationItem.leftBarButtonItem?.isEnabled = true
    }
}

extension ClientViewController : ClientActionDelegate
{
    func connect(hostAddress: String)
    {
        customView?.beginConnecting()
        presenter?.connect(hostAddress: hostAddress)
    }
}
