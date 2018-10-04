//
//  HostGameplayViewController.swift
//  CowsAndBulls
//
//  Created by Kristiyan Butev on 2.10.18.
//  Copyright © 2018 Kristiyan Butev. All rights reserved.
//

import UIKit

class HostGameplayViewController: UIViewController
{
    private var customView: HostGameplayView?
    
    private var presenter: HostGameplayPresenterDelegate? = nil
    
    init(withPresenter presenter: HostGameplayPresenter)
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
        self.customView = self.view as? HostGameplayView
        self.customView?.delegate = self
    }
}

extension HostGameplayViewController : HostGameplayViewDelegate
{
    func connectionFailure(errorMessage: String)
    {
        presenter?.quit()
        
        navigationController?.popToRootViewController(animated: false)
    }
}

extension HostGameplayViewController : HostGameplayActionDelegate
{
    
}
