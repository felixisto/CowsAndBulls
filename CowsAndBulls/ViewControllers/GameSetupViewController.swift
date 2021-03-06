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
    
    private let presenter: GameSetupPresenterDelegate?
    
    init(withPresenter presenter: GameSetupPresenter)
    {
        self.presenter = presenter
        
        super.init(nibName: nil, bundle: nil)
        
        presenter.delegate = self
    }
    
    required init?(coder aDecoder: NSCoder)
    {
        self.presenter = nil
        
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
        navigationItem.title = "Game Setup"
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Quit", style: .plain, target: self, action: #selector(actionBack(_:)))
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Agree?", style: .plain, target: self, action: #selector(actionNext(_:)))
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
        
        presenter?.pickCurrentPlaySetupAndSendToOpponent()
    }
}

extension GameSetupViewController : GameSetupViewDelegate
{
    func updateNumberOfCharactersPicker(dataSource: GameSetupWordLengthPickerViewDataSource?, delegate: GameSetupWordLengthPickerViewDelegate?)
    {
        customView?.updateNumberOfCharactersPicker(dataSource: dataSource, delegate: delegate)
    }
    
    func updateTurnToGoPicker(dataSource: GameSetupTurnPickerViewDataSource?, delegate: GameSetupTurnPickerViewDelegate?)
    {
        customView?.updateTurnToGoPicker(dataSource: dataSource, delegate: delegate)
    }
    
    func updateConnectionData(playerAddress: String, playerName: String, playerColor: UIColor)
    {
        customView?.updateConnectionData(playerAddress: playerAddress, playerName: playerName, playerColor: playerColor)
    }
    
    func connectionFailure()
    {
        presenter?.quit()
        
        if let window = UIApplication.shared.delegate?.window
        {
            window?.rootViewController = UINavigationController(rootViewController: MainViewController(withWindow: window, withPresenter: MainPresenter(initialConnectionStatus: .quit)))
        }
        else
        {
            navigationController?.popToRootViewController(animated: false)
        }
    }
    
    func connectionFailure(errorMessage: String)
    {
        presenter?.quit()
        
        if let window = UIApplication.shared.delegate?.window
        {
            window?.rootViewController = UINavigationController(rootViewController: MainViewController(withWindow: window, withPresenter: MainPresenter(initialConnectionStatus: .disconnected)))
        }
        else
        {
            navigationController?.popToRootViewController(animated: false)
        }
    }
    
    func updateOpponentPlaySetup(guessWordLength: UInt, turnToGo: String)
    {
        customView?.updateOpponentStatus(guessWordLength: guessWordLength, turnToGo: turnToGo)
    }
    
    func playSetupMismatch()
    {
        customView?.enableUserInteraction()
        
        navigationItem.rightBarButtonItem?.isEnabled = true
        
        presenter?.playSetupMismatchesOpponentPlayerSetup()
        
        let alert = UIAlertController(title: "Setup mismatch", message: "Your picked values must not contradict the opponent's values", preferredStyle: .alert)
        
        alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
        
        self.present(alert, animated: true, completion: nil)
    }
    
    func playSetupMatch()
    {
        presenter?.playSetupMatchesOpponentPlayerSetup()
    }
    
    func goToPickWordScreen(communicator: Communicator?, connectionData: CommunicatorInitialConnection, guessWordLength: UInt, turnToGo: GameTurn)
    {
        if let comm = communicator, var viewControllers = navigationController?.viewControllers
        {
            let presenter = PickWordPresenter(communicator: comm, connectionData: connectionData, guessWordLength: guessWordLength, turnToGo: turnToGo)
            let viewController = PickWordViewController(withPresenter: presenter)
            
            viewControllers.insert(viewController, at: viewControllers.count)
            
            navigationController?.viewControllers = viewControllers
        }
    }
    
    func lostConnectingAttemptingToReconnect()
    {
        customView?.changeConnectionStatusToReconnecting()
    }
    
    func reconnect()
    {
        customView?.changeConnectionStatusToReconnected()
    }
}

extension GameSetupViewController : GameSetupActionDelegate
{
    func didSelectGuessWordCharacterCount(number: UInt)
    {
        presenter?.didSelectGuessWordCharacterCount(number: number)
    }
    
    func didSelectTurnToGo(turnToGo: String)
    {
        presenter?.didSelectTurnToGo(turnToGo: turnToGo)
    }
}
