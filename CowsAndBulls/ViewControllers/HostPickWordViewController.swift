//
//  HostPickWordViewController.swift
//  CowsAndBulls
//
//  Created by Kristiyan Butev on 2.10.18.
//  Copyright © 2018 Kristiyan Butev. All rights reserved.
//

import UIKit

class HostPickWordViewController: UIViewController
{
    private var customView: HostPickWordView?
    
    private var presenter: HostPickWordPresenterDelegate? = nil
    
    init(withPresenter presenter: HostPickWordPresenter)
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
        self.customView = self.view as? HostPickWordView
        self.customView?.delegate = self
    }
}

extension HostPickWordViewController : HostPickWordViewDelegate
{
    
}

extension HostPickWordViewController : HostPickWordActionDelegate
{
    
}
