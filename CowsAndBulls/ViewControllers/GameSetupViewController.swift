//
//  GameSetupViewController.swift
//  CowsAndBulls
//
//  Created by Kristiyan Butev on 2.10.18.
//  Copyright © 2018 Kristiyan Butev. All rights reserved.
//

import UIKit

class GameSetupViewController: UIViewController
{
    private var customView: GameSetupView?
    
    private var presenter: GameSetupPresenterDelegate? = nil
    
    init(withPresenter presenter: GameSetupPresenter)
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
        
        presenter?.start()
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
        self.customView = self.view as? GameSetupView
        self.customView?.delegate = self
        
        navigationController?.navigationBar.isHidden = false
        navigationItem.title = "Pick Role"
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Quit", style: .plain, target: self, action: #selector(actionBack(_:)))
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Next", style: .plain, target: self, action: #selector(actionNext(_:)))
    }
}

extension GameSetupViewController
{
    @objc func actionBack(_ sender: Any)
    {
        presenter?.quit()
        
        navigationController?.popToRootViewController(animated: false)
    }
    
    @objc func actionNext(_ sender: Any)
    {
        customView?.disableUserInteraction()
        
        navigationItem.rightBarButtonItem?.isEnabled = false
        
        presenter?.pickAndSendGuessWorCharacterCountToOpponent()
    }
}

extension GameSetupViewController : GameSetupViewDelegate
{
    func updateNumberOfCharactersPicker(dataSource: GameSetupPickerViewDataSource?, delegate: GameSetupPickerViewDelegate?)
    {
        customView?.updateNumberOfCharactersPicker(dataSource: dataSource, delegate: delegate)
    }
    
    func updateConnectionData(playerAddress: String, playerName: String, playerColor: UIColor)
    {
        customView?.updateConnectionData(playerAddress: playerAddress, playerName: playerName, playerColor: playerColor)
    }
    
    func connectionFailure(errorMessage: String)
    {
        presenter?.quit()
        
        navigationController?.popToRootViewController(animated: false)
    }
    
    func didSelectGuessWordCharacterCount(number: UInt)
    {
        presenter?.didSelectGuessWordCharacterCount(number: number)
    }
    
    func opponentDidSelectGuessWordCharacterCount(number: UInt)
    {
        customView?.setOpponentGuessWordLength(length: number)
    }
    
    func guessWordCharacterCountMismatch()
    {
        customView?.enableUserInteraction()
        
        navigationItem.rightBarButtonItem?.isEnabled = true
        
        presenter?.guessWordCharacterCountMismatch()
    }
    
    func guessWordCharacterCountMatch()
    {
        presenter?.guessWordCharacterCountMatch()
    }
    
    func goToPickWord(communicator: Communicator?, withGuessWordLength guessWordLength: UInt)
    {
        if let comm = communicator
        {
            let presenter = PickWordPresenter(communicator: comm, guessWordLength: guessWordLength)
            let viewController = PickWordViewController(withPresenter: presenter)
            
            navigationController?.pushViewController(viewController, animated: true)
        }
    }
}

extension GameSetupViewController : GameSetupActionDelegate
{
    
}
