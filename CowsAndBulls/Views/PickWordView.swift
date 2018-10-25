//
//  PickWordView.swift
//  CowsAndBulls
//
//  Created by Kristiyan Butev on 2.10.18.
//  Copyright © 2018 Kristiyan Butev. All rights reserved.
//

import UIKit
import PinCodeTextField

protocol PickWordViewDelegate : class
{
    func goToGameplayScreen(communicator: Communicator?, connectionData: CommunicatorInitialConnection, gameSession: GameSession)
    func invalidGuessWord(error: String)
    func setOpponentStatus(status: String)
    func updateEnterXCharacterWord(length: UInt)
    func updateConnectionData(playerAddress: String, playerName: String, playerColor: UIColor)
    func nextGame()
    
    func connectionFailure()
    func connectionFailure(errorMessage: String)
    
    func lostConnectingAttemptingToReconnect()
    func reconnect()
}

protocol PickWordActionDelegate : PinCodeTextFieldDelegate
{
    
}

class PickWordView : UIView
{
    static let ALERT_MESSAGE_RECONNECTING = "Lost connection. Reconnecting..."
    static let ALERT_MESSAGE_RECONNECTED = "Reconnected!"
    
    weak var delegate : PickWordActionDelegate?
    @IBOutlet weak var labelInfo: UILabel!
    @IBOutlet private weak var labelTip: UILabel!
    @IBOutlet private weak var labelOpponentStatus: UILabel!
    @IBOutlet private weak var pincodeGuessWord: PinCodeTextField!
    @IBOutlet private weak var layoutConnectionStatus: UIView!
    @IBOutlet private weak var labelConnectionStatus: UILabel!
    
    override init(frame: CGRect)
    {
        super.init(frame: frame)
    }
    
    required init?(coder aDecoder: NSCoder)
    {
        super.init(coder: aDecoder)
    }
    
    override func didMoveToSuperview()
    {
        setup()
    }
    
    func setup()
    {
        let guide = self.safeAreaLayoutGuide
        
        labelInfo.translatesAutoresizingMaskIntoConstraints = false
        labelInfo.topAnchor.constraint(equalTo: guide.topAnchor, constant: 10.0).isActive = true
        labelInfo.centerXAnchor.constraint(equalTo: guide.centerXAnchor).isActive = true
        labelInfo.textAlignment = .center
        
        labelTip.translatesAutoresizingMaskIntoConstraints = false
        labelTip.topAnchor.constraint(equalTo: labelInfo.bottomAnchor, constant: 30.0).isActive = true
        labelTip.centerXAnchor.constraint(equalTo: guide.centerXAnchor).isActive = true
        labelTip.textAlignment = .center
        
        pincodeGuessWord.translatesAutoresizingMaskIntoConstraints = false
        pincodeGuessWord.topAnchor.constraint(equalTo: labelTip.bottomAnchor, constant: 10.0).isActive = true
        pincodeGuessWord.centerXAnchor.constraint(equalTo: guide.centerXAnchor).isActive = true
        pincodeGuessWord.widthAnchor.constraint(equalTo: guide.widthAnchor, multiplier: 1.0).isActive = true
        pincodeGuessWord.heightAnchor.constraint(equalToConstant: 128.0).isActive = true
        pincodeGuessWord.allowedCharacterSet = CharacterSet.decimalDigits
        pincodeGuessWord.keyboardType = .decimalPad
        
        labelOpponentStatus.translatesAutoresizingMaskIntoConstraints = false
        labelOpponentStatus.bottomAnchor.constraint(equalTo: guide.bottomAnchor, constant: -10.0).isActive = true
        labelOpponentStatus.centerXAnchor.constraint(equalTo: guide.centerXAnchor).isActive = true
        labelOpponentStatus.textAlignment = .center
        
        layoutConnectionStatus.translatesAutoresizingMaskIntoConstraints = false
        layoutConnectionStatus.centerXAnchor.constraint(equalTo: guide.centerXAnchor).isActive = true
        layoutConnectionStatus.centerYAnchor.constraint(equalTo: guide.centerYAnchor).isActive = true
        layoutConnectionStatus.widthAnchor.constraint(equalTo: guide.widthAnchor, multiplier: 1.0).isActive = true
        layoutConnectionStatus.heightAnchor.constraint(equalToConstant: 32.0).isActive = true
        layoutConnectionStatus.isHidden = true
        
        labelConnectionStatus.translatesAutoresizingMaskIntoConstraints = false
        labelConnectionStatus.centerXAnchor.constraint(equalTo: layoutConnectionStatus.centerXAnchor).isActive = true
        labelConnectionStatus.centerYAnchor.constraint(equalTo: layoutConnectionStatus.centerYAnchor).isActive = true
        labelConnectionStatus.textAlignment = .center
    }
}

// Methods for updating the interface
extension PickWordView
{
    func setNumberOfCharacters(length: UInt)
    {
        DispatchQueue.main.async {
            self.labelTip.text = String("Enter \(length) digit guess word")
            
            self.pincodeGuessWord.characterLimit = Int(length)
            self.pincodeGuessWord.text = "1"
            self.pincodeGuessWord.text = ""
        }
    }
    
    func setOpponentStatus(status: String)
    {
        DispatchQueue.main.async {
            self.labelOpponentStatus.text = status
        }
    }
    
    func updateConnectionData(playerAddress: String, playerName: String, playerColor: UIColor)
    {
        DispatchQueue.main.async {
            self.labelInfo.text = String("Opponent: \(playerName) (\(playerAddress))")
        }
    }
    
    func enablePincode()
    {
        DispatchQueue.main.async {
            self.pincodeGuessWord.isUserInteractionEnabled = true
        }
    }
    
    func disablePincode()
    {
        DispatchQueue.main.async {
            self.pincodeGuessWord.isUserInteractionEnabled = false
        }
    }
    
    func clearPincode()
    {
        DispatchQueue.main.async {
            self.pincodeGuessWord.text = ""
        }
    }
    
    func stopPincodeKeyboard()
    {
        DispatchQueue.main.async {
            self.pincodeGuessWord.resignFirstResponder()
        }
    }
    
    func setActionDelegate(delegate: PinCodeTextFieldDelegate?)
    {
        DispatchQueue.main.async {
            self.pincodeGuessWord.delegate = delegate
        }
    }
    
    func hideConnectionStatus()
    {
        DispatchQueue.main.async {
            self.layoutConnectionStatus.isHidden = true
        }
    }
    
    func changeConnectionStatusToReconnecting()
    {
        DispatchQueue.main.async {
            self.layoutConnectionStatus.isHidden = false
            self.layoutConnectionStatus.backgroundColor = .orange
            self.labelConnectionStatus.text = PickWordView.ALERT_MESSAGE_RECONNECTING
        }
    }
    
    func changeConnectionStatusToReconnected()
    {
        DispatchQueue.main.async {
            self.layoutConnectionStatus.isHidden = false
            self.layoutConnectionStatus.backgroundColor = .green
            self.labelConnectionStatus.text = PickWordView.ALERT_MESSAGE_RECONNECTED
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) {
                if !self.layoutConnectionStatus.isHidden && self.labelConnectionStatus.text == PickWordView.ALERT_MESSAGE_RECONNECTED
                {
                    self.hideConnectionStatus()
                }
            }
        }
    }
}

extension PickWordView
{
    class func create(owner: Any) -> PickWordView?
    {
        let bundle = Bundle.main
        let nibName = String(describing: PickWordView.self)
        let nib = UINib(nibName: nibName, bundle: bundle)
        
        return nib.instantiate(withOwner: owner, options: nil).first as? PickWordView
    }
}
