//
//  PickWordViewController.swift
//  CowsAndBulls
//
//  Created by Kristiyan Butev on 2.10.18.
//  Copyright © 2018 Kristiyan Butev. All rights reserved.
//

import UIKit
import PinCodeTextField

class PickWordViewController: UIViewController
{
    private var customView: PickWordView?
    
    private let presenter: PickWordPresenterDelegate?
    
    init(withPresenter presenter: PickWordPresenter)
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
    }
    
    override func viewWillAppear(_ animated: Bool)
    {
        super.viewWillAppear(animated)
        
        presenter?.start()
    }
    
    override func viewWillDisappear(_ animated: Bool)
    {
        // Prepare for new game
        self.presenter?.prepareForNewGame()
        
        customView?.clearPincode()
        
        customView?.setOpponentStatus(status: "Opponent is picking a guess word...")
    }
    
    override func didReceiveMemoryWarning()
    {
        super.didReceiveMemoryWarning()
    }
    
    private func initInterface()
    {
        self.customView = self.view as? PickWordView
        self.customView?.delegate = self
        
        navigationController?.navigationBar.isHidden = false
        navigationItem.title = "Pick Guess Word"
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Quit", style: .plain, target: self, action: #selector(actionBack(_:)))
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Play!", style: .plain, target: self, action: #selector(actionPlay(_:)))
    }
}

extension PickWordViewController
{
    @objc func actionBack(_ sender: Any)
    {
        presenter?.quit()
        
        navigationController?.popToRootViewController(animated: false)
    }
    
    @objc func actionPlay(_ sender: Any)
    {
        let guessWord = ""
        
        presenter?.goToGameplayScreen(guessWord: guessWord)
    }
}

extension PickWordViewController : PickWordViewDelegate
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
    
    func setOpponentStatus(status: String)
    {
        customView?.setOpponentStatus(status: status)
    }
    
    func updateEnterXCharacterWord(length: UInt)
    {
        customView?.setNumberOfCharacters(length: length)
    }
    
    func invalidGuessWord(error: String)
    {
        let alert = UIAlertController(title: "Invalid guess word", message: error, preferredStyle: .alert)
        
        customView?.clearPincode()
        
        alert.addAction(UIAlertAction(title: "Try again", style: .default, handler: nil))
        
        self.present(alert, animated: true, completion: nil)
    }
    
    func goToGameplayScreen(communicator: Communicator?, connectionData: CommunicatorInitialConnection, gameSession: GameSession)
    {
        if let comm = communicator
        {
            let presenter = GameplayPresenter(communicator: comm, connectionData: connectionData, gameSession: gameSession)
            let viewController = GameplayViewController(withPresenter: presenter)
            
            navigationController?.pushViewController(viewController, animated: true)
        }
    }
    
    func updateConnectionData(playerAddress: String, playerName: String, playerColor: UIColor)
    {
        customView?.updateConnectionData(playerAddress: playerAddress, playerName: playerName, playerColor: playerColor)
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

extension PickWordViewController : PickWordActionDelegate
{
    func textFieldDidEndEditing(_ textField: PinCodeTextField)
    {
        if let text = textField.text
        {
            presenter?.goToGameplayScreen(guessWord: text)
        }
    }
}
