//
//  GuesserGameplayViewController.swift
//  CowsAndBulls
//
//  Created by Kristiyan Butev on 2.10.18.
//  Copyright © 2018 Kristiyan Butev. All rights reserved.
//

import UIKit

class GuesserGameplayViewController: UIViewController
{
    private var customView: GuesserGameplayView?
    
    private var presenter: GuesserGameplayPresenterDelegate? = nil
    
    init(withPresenter presenter: GuesserGameplayPresenter)
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
        self.customView = self.view as? GuesserGameplayView
        self.customView?.delegate = self
    }
}

extension GuesserGameplayViewController : GuesserGameplayViewDelegate
{
    
}

extension GuesserGameplayViewController : GuesserGameplayActionDelegate
{
    
}

