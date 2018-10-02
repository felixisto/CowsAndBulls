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
    
    private var presenter: MainPresenterDelegate? = nil
    
    init(withWindow window: UIWindow?, withPresenter presenter: MainPresenter)
    {
        self.window = window
        
        super.init(nibName: nil, bundle: nil)
        
        self.presenter = presenter
        presenter.delegate = self
    }
    
    required init?(coder aDecoder: NSCoder)
    {
        self.window = nil
        
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
        self.customView = self.view as? MainView
        self.customView?.delegate = self
        
        navigationItem.title = "Cows & Bulls"
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
        navigationController?.pushViewController(JoinViewController(withPresenter: JoinPresenter()), animated: true)
    }
}
