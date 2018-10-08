//
//  GameplayViewController.swift
//  CowsAndBulls
//
//  Created by Kristiyan Butev on 2.10.18.
//  Copyright © 2018 Kristiyan Butev. All rights reserved.
//

import UIKit
import PinCodeTextField

class GameplayViewController: UIViewController
{
    private var customView: GameplayView?
    
    private let presenter: GameplayPresenterDelegate?
    
    init(withPresenter presenter: GameplayPresenter)
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
        
        customView?.setActionDelegate(delegate: self)
        
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
    
    func setupUI(guessCharacters: UInt, playerLabel: String, myGuessWord: String, firstToGo: Bool)
    {
        customView?.setNumberOfCharacters(length: guessCharacters)
        customView?.setOpponentLabel(label: playerLabel)
        customView?.setGuessWord(guess: myGuessWord)
        
        customView?.setCurrentTurn(turn: 1, myTurn: firstToGo)
    }
    
    func setCurrentTurnValue(turn: UInt, myTurn: Bool)
    {
        customView?.setCurrentTurn(turn: turn, myTurn: myTurn)
    }
    
    func updateLog(string: String)
    {
        customView?.updateLog(string: string)
    }
    
    func lostConnectingAttemptingToReconnect()
    {
        customView?.changeConnectionStatusToReconnecting()
    }
    
    func reconnect()
    {
        customView?.changeConnectionStatusToReconnected()
    }
    
    func victory()
    {
        customView?.showVictoryScreen()
        
        navigationItem.leftBarButtonItem?.isEnabled = false
    }
    
    func defeat()
    {
        customView?.showDefeatScreen()
        
        navigationItem.leftBarButtonItem?.isEnabled = false
    }
}

extension GameplayViewController : GameplayActionDelegate
{
    func textFieldDidEndEditing(_ textField: PinCodeTextField)
    {
        if let text = textField.text
        {
            presenter?.guess(guess: text)
            customView?.hidePincode()
        }
    }
    
    func leaveOutcomeScreen()
    {
        navigationController?.popViewController(animated: false)
    }
}
