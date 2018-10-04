//
//  GuesserPickWordViewController.swift
//  CowsAndBulls
//
//  Created by Kristiyan Butev on 2.10.18.
//  Copyright © 2018 Kristiyan Butev. All rights reserved.
//

import UIKit

class GuesserPickWordViewController: UIViewController
{
    private var customView: GuesserPickWordView?
    
    private var presenter: GuesserPickWordPresenterDelegate? = nil
    
    init(withPresenter presenter: GuesserPickWordPresenter)
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
        self.customView = self.view as? GuesserPickWordView
        self.customView?.delegate = self
    }
}

extension GuesserPickWordViewController : GuesserPickWordViewDelegate
{
    func connectionFailure(errorMessage: String)
    {
        presenter?.quit()
        
        navigationController?.popToRootViewController(animated: false)
    }
}

extension GuesserPickWordViewController : GuesserPickWordActionDelegate
{
    
}
