//
//  GameplayViewController.swift
//  CowsAndBulls
//
//  Created by Kristiyan Butev on 2.10.18.
//  Copyright © 2018 Kristiyan Butev. All rights reserved.
//

import UIKit

class GameplayViewController: UIViewController
{
    private var customView: GameplayView?
    
    private var presenter: GameplayPresenterDelegate? = nil
    
    init(withPresenter presenter: GameplayPresenter)
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
        self.customView = self.view as? GameplayView
        self.customView?.delegate = self
        
        navigationController?.navigationBar.isHidden = false
        navigationItem.title = "Cows & Bulls"
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Surrender!", style: .plain, target: self, action: #selector(actionSurrender(_:)))
    }
}

extension GameplayViewController
{
    @objc func actionSurrender(_ sender: Any)
    {
        let alert = UIAlertController(title: "Surrender", message: "Are you sure you want to leave the game?", preferredStyle: .alert)
        
        alert.addAction(UIAlertAction(title: "Leave", style: .default, handler: {sender -> Void in
            self.presenter?.quit()
            
            self.navigationController?.popToRootViewController(animated: false)
        }))
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .default, handler: nil))
        
        self.present(alert, animated: true, completion: nil)
    }
}

extension GameplayViewController : GameplayViewDelegate
{
    func connectionFailure(errorMessage: String)
    {
        presenter?.quit()
        
        navigationController?.popToRootViewController(animated: false)
    }
}

extension GameplayViewController : GameplayActionDelegate
{
    
}
