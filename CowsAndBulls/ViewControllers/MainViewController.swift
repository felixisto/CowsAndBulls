//
//  MainViewController.swift
//  CowsAndBulls
//
//  Created by Kristiyan Butev on 2.10.18.
//  Copyright © 2018 Kristiyan Butev. All rights reserved.
//

import UIKit

class MainViewController: UIViewController
{
    private let window: UIWindow?
    
    private var customView: MainView?
    
    private let presenter: MainPresenterDelegate?
    
    private let initialConnectionStatus : MainPresenterConnectionStatus
    
    init(withWindow window: UIWindow?, withPresenter presenter: MainPresenter)
    {
        self.window = window
        
        self.presenter = presenter
        
        self.initialConnectionStatus = presenter.initialConnectionStatus
        
        super.init(nibName: nil, bundle: nil)
        
        presenter.delegate = self
    }
    
    required init?(coder aDecoder: NSCoder)
    {
        self.window = nil
        
        self.presenter = nil
        
        self.initialConnectionStatus = .none
        
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
        
        navigationController?.navigationBar.isHidden = true
    }
    
    override func didReceiveMemoryWarning()
    {
        super.didReceiveMemoryWarning()
    }
    
    override var prefersStatusBarHidden : Bool {
        get {
            return true
        }
    }
    
    private func initInterface()
    {
        self.customView = self.view as? MainView
        self.customView?.delegate = self
        
        navigationController?.navigationBar.isHidden = true
        
        // Connection status
        switch initialConnectionStatus {
        case .quit:
            customView?.changeConnectionStatusToQuit()
        case .disconnected:
            customView?.changeConnectionStatusToDisconnected()
        default: break
        }
    }
}

extension MainViewController : MainViewDelegate
{
    
}

extension MainViewController : MainActionDelegate
{
    func host()
    {
        navigationController?.pushViewController(HostViewController(withPresenter: HostPresenter()), animated: true)
    }
    
    func join()
    {
        navigationController?.pushViewController(ClientViewController(withPresenter: ClientPresenter()), animated: true)
    }
}
