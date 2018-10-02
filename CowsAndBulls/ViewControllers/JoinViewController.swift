//
//  JoinViewController.swift
//  CowsAndBulls
//
//  Created by Kristiyan Butev on 2.10.18.
//  Copyright © 2018 Kristiyan Butev. All rights reserved.
//

import UIKit

class JoinViewController: UIViewController
{
    private var customView: JoinView?
    
    private var presenter: JoinPresenterDelegate? = nil
    
    init(withPresenter presenter: JoinPresenter)
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
        self.customView = self.view as? JoinView
        self.customView?.delegate = self
        
        navigationItem.title = "Join game"
    }
}

extension JoinViewController : JoinViewDelegate
{
    func connectionSuccessful(communicator: Communicator?)
    {
        navigationController?.pushViewController(PickRoleViewController(withPresenter: PickRolePresenter()), animated: true)
    }
    
    func connectionFailure(errorMessage: String)
    {
        customView?.stopConnecting()
    }
}

extension JoinViewController : JoinActionDelegate
{
    func connect(hostAddress: String)
    {
        customView?.beginConnecting()
        presenter?.connect(hostAddress: hostAddress)
    }
}
