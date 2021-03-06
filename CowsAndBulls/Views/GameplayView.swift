//
//  GameplayView.swift
//  CowsAndBulls
//
//  Created by Kristiyan Butev on 2.10.18.
//  Copyright © 2018 Kristiyan Butev. All rights reserved.
//

import UIKit
import PinCodeTextField

protocol GameplayViewDelegate : class
{
    func connectionFailure()
    func connectionFailure(errorMessage: String)
    
    func setupUI(guessCharacters: UInt, playerLabel: String, myGuessWord: String, firstToGo: Bool)
    
    func setCurrentTurnValue(turn: UInt, myTurn: Bool)
    
    func updateLog(string: String)
    
    func lostConnectingAttemptingToReconnect()
    func reconnect()
    
    func victory(opponentGuessWord: String)
    func defeat(myGuessWord: String)
    
    func goBack()
}

protocol GameplayActionDelegate : PinCodeTextFieldDelegate
{
    func chat(message: String)
    func leaveOutcomeScreen()
}

class GameplayView : UIView
{
    static let ALERT_MESSAGE_RECONNECTING = "Lost connection. Reconnecting..."
    static let ALERT_MESSAGE_RECONNECTED = "Reconnected!"
    
    weak var delegate : GameplayActionDelegate?
    
    @IBOutlet private weak var labelGameDescription: UILabel!
    @IBOutlet private weak var labelYourGuessWord: UILabel!
    @IBOutlet private weak var labelTurn: UILabel!
    @IBOutlet private weak var labelLog: UILabel!
    @IBOutlet private weak var scrollLog: UIScrollView!
    @IBOutlet private weak var labelStatus: UILabel!
    @IBOutlet private weak var buttonGuess: UIButton!
    @IBOutlet private weak var buttonChat: UIButton!
    
    @IBOutlet private weak var labelPincodeGuess: UILabel!
    @IBOutlet private weak var pincodeGuess: PinCodeTextField!
    
    @IBOutlet private weak var labelChat: UILabel!
    @IBOutlet private weak var fieldChat: UITextField!
    
    @IBOutlet private weak var buttonCancel: UIButton!
    
    @IBOutlet private weak var layoutConnectionStatus: UIView!
    @IBOutlet private weak var labelConnectionStatus: UILabel!
    
    @IBOutlet private weak var layoutOutcomeScreen: UIView!
    @IBOutlet private weak var labelOutcome: UILabel!
    
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
        
        labelYourGuessWord.translatesAutoresizingMaskIntoConstraints = false
        labelYourGuessWord.topAnchor.constraint(equalTo: guide.topAnchor, constant: 15.0).isActive = true
        labelYourGuessWord.leadingAnchor.constraint(equalTo: guide.leadingAnchor, constant: 15.0).isActive = true
        labelYourGuessWord.textAlignment = .left
        
        labelGameDescription.translatesAutoresizingMaskIntoConstraints = false
        labelGameDescription.topAnchor.constraint(equalTo: labelYourGuessWord.bottomAnchor, constant: 15.0).isActive = true
        labelGameDescription.leadingAnchor.constraint(equalTo: guide.leadingAnchor, constant: 15.0).isActive = true
        labelGameDescription.textAlignment = .left
        
        labelTurn.translatesAutoresizingMaskIntoConstraints = false
        labelTurn.topAnchor.constraint(equalTo: labelGameDescription.bottomAnchor, constant: 15.0).isActive = true
        labelTurn.centerXAnchor.constraint(equalTo: guide.centerXAnchor).isActive = true
        labelTurn.textAlignment = .center
        
        
        
        buttonGuess.translatesAutoresizingMaskIntoConstraints = false
        buttonGuess.bottomAnchor.constraint(equalTo: guide.bottomAnchor, constant: 5.0).isActive = true
        buttonGuess.leadingAnchor.constraint(equalTo: guide.leadingAnchor, constant: 5.0).isActive = true
        buttonGuess.addTarget(self, action: #selector(actionGuess(_:)), for: .touchDown)
        buttonGuess.setTitleColor(UIColor.gray, for: .disabled)
        
        buttonChat.translatesAutoresizingMaskIntoConstraints = false
        buttonChat.bottomAnchor.constraint(equalTo: guide.bottomAnchor, constant: 5.0).isActive = true
        buttonChat.trailingAnchor.constraint(equalTo: guide.trailingAnchor, constant: -5.0).isActive = true
        buttonChat.addTarget(self, action: #selector(actionChat(_:)), for: .touchDown)
        
        buttonCancel.translatesAutoresizingMaskIntoConstraints = false
        buttonCancel.topAnchor.constraint(equalTo: guide.topAnchor, constant: 5.0).isActive = true
        buttonCancel.trailingAnchor.constraint(equalTo: guide.trailingAnchor, constant: -5.0).isActive = true
        buttonCancel.addTarget(self, action: #selector(actionCancel(_:)), for: .touchDown)
        
        labelStatus.translatesAutoresizingMaskIntoConstraints = false
        labelStatus.bottomAnchor.constraint(equalTo: guide.bottomAnchor, constant: -10.0).isActive = true
        labelStatus.centerXAnchor.constraint(equalTo: guide.centerXAnchor).isActive = true
        labelStatus.textAlignment = .center
        
        
        
        
        
        
        labelPincodeGuess.translatesAutoresizingMaskIntoConstraints = false
        labelPincodeGuess.centerXAnchor.constraint(equalTo: guide.centerXAnchor).isActive = true
        labelPincodeGuess.bottomAnchor.constraint(equalTo: pincodeGuess.topAnchor, constant: 15.0).isActive = true
        labelPincodeGuess.textAlignment = .center
        
        pincodeGuess.translatesAutoresizingMaskIntoConstraints = false
        pincodeGuess.centerXAnchor.constraint(equalTo: guide.centerXAnchor).isActive = true
        pincodeGuess.centerYAnchor.constraint(equalTo: guide.centerYAnchor).isActive = true
        pincodeGuess.widthAnchor.constraint(equalTo: guide.widthAnchor, multiplier: 0.9).isActive = true
        pincodeGuess.heightAnchor.constraint(equalToConstant: 128.0).isActive = true
        pincodeGuess.allowedCharacterSet = CharacterSet.decimalDigits
        pincodeGuess.keyboardType = .decimalPad
        
        scrollLog.translatesAutoresizingMaskIntoConstraints = false
        scrollLog.centerXAnchor.constraint(equalTo: guide.centerXAnchor).isActive = true
        scrollLog.topAnchor.constraint(equalTo: labelTurn.bottomAnchor, constant: 40.0).isActive = true
        scrollLog.widthAnchor.constraint(equalTo: guide.widthAnchor, multiplier: 0.9).isActive = true
        scrollLog.heightAnchor.constraint(equalToConstant: 196.0).isActive = true
        
        labelLog.translatesAutoresizingMaskIntoConstraints = false
        labelLog.widthAnchor.constraint(equalTo: scrollLog.widthAnchor, multiplier: 1.0).isActive = true
        labelLog.heightAnchor.constraint(equalTo: labelLog.heightAnchor, multiplier: 1.0).isActive = true
        labelLog.numberOfLines = 10000
        labelLog.textAlignment = .left
        
        
        
        
        
        labelChat.translatesAutoresizingMaskIntoConstraints = false
        labelChat.centerXAnchor.constraint(equalTo: guide.centerXAnchor).isActive = true
        labelChat.bottomAnchor.constraint(equalTo: pincodeGuess.topAnchor, constant: 15.0).isActive = true
        labelChat.textAlignment = .center
        
        fieldChat.translatesAutoresizingMaskIntoConstraints = false
        fieldChat.centerXAnchor.constraint(equalTo: guide.centerXAnchor).isActive = true
        fieldChat.centerYAnchor.constraint(equalTo: guide.centerYAnchor).isActive = true
        fieldChat.widthAnchor.constraint(equalTo: guide.widthAnchor, multiplier: 0.9).isActive = true
        fieldChat.heightAnchor.constraint(equalToConstant: 32.0).isActive = true
        fieldChat.delegate = self
        
        
        
        layoutConnectionStatus.translatesAutoresizingMaskIntoConstraints = false
        layoutConnectionStatus.centerXAnchor.constraint(equalTo: guide.centerXAnchor).isActive = true
        layoutConnectionStatus.centerYAnchor.constraint(equalTo: guide.centerYAnchor).isActive = true
        layoutConnectionStatus.widthAnchor.constraint(equalTo: guide.widthAnchor, multiplier: 1.0).isActive = true
        layoutConnectionStatus.heightAnchor.constraint(equalToConstant: 32.0).isActive = true
        
        labelConnectionStatus.translatesAutoresizingMaskIntoConstraints = false
        labelConnectionStatus.centerXAnchor.constraint(equalTo: layoutConnectionStatus.centerXAnchor).isActive = true
        labelConnectionStatus.centerYAnchor.constraint(equalTo: layoutConnectionStatus.centerYAnchor).isActive = true
        labelConnectionStatus.textAlignment = .center
        
        
        
        
        
        
        layoutOutcomeScreen.translatesAutoresizingMaskIntoConstraints = false
        layoutOutcomeScreen.topAnchor.constraint(equalTo: self.topAnchor).isActive = true
        layoutOutcomeScreen.bottomAnchor.constraint(equalTo: self.bottomAnchor).isActive = true
        layoutOutcomeScreen.leadingAnchor.constraint(equalTo: self.leadingAnchor).isActive = true
        layoutOutcomeScreen.trailingAnchor.constraint(equalTo: self.trailingAnchor).isActive = true
        layoutOutcomeScreen.isHidden = true
        layoutOutcomeScreen.isUserInteractionEnabled = false
        let gesture = UITapGestureRecognizer(target: self, action: #selector(actionLeaveOutcomeScreen(_:)))
        gesture.numberOfTapsRequired = 1
        gesture.numberOfTouchesRequired = 1
        layoutOutcomeScreen.addGestureRecognizer(gesture)
        bringSubviewToFront(layoutOutcomeScreen)
        
        labelOutcome.translatesAutoresizingMaskIntoConstraints = false
        labelOutcome.centerXAnchor.constraint(equalTo: layoutOutcomeScreen.centerXAnchor).isActive = true
        labelOutcome.centerYAnchor.constraint(equalTo: layoutOutcomeScreen.centerYAnchor).isActive = true
        labelOutcome.widthAnchor.constraint(equalTo: layoutOutcomeScreen.widthAnchor, multiplier: 1.0).isActive = true
        labelOutcome.numberOfLines = 10
        
        // Layout connection status should be ontop of everything, including the outcome screen
        bringSubviewToFront(layoutConnectionStatus)
    }
    
    private func hideBase()
    {
        self.labelGameDescription.isHidden = true
        self.labelYourGuessWord.isHidden = true
        self.labelTurn.isHidden = true
        self.scrollLog.isHidden = true
        self.labelStatus.isHidden = true
        
        self.buttonGuess.isHidden = true
        self.buttonChat.isHidden = true
    }
    
    private func showBase()
    {
        self.labelGameDescription.isHidden = false
        self.labelYourGuessWord.isHidden = false
        self.labelTurn.isHidden = false
        self.scrollLog.isHidden = false
        self.labelStatus.isHidden = false
        
        self.buttonGuess.isHidden = false
        self.buttonChat.isHidden = false
        
        self.pincodeGuess.resignFirstResponder()
        self.fieldChat.resignFirstResponder()
    }
}

// Methods for updating the interface
extension GameplayView
{
    func setNumberOfCharacters(length: UInt)
    {
        DispatchQueue.main.async {
            self.pincodeGuess.characterLimit = Int(length)
            self.pincodeGuess.text = "1"
            self.pincodeGuess.text = ""
        }
    }
    
    func setOpponentLabel(label: String)
    {
        DispatchQueue.main.async {
            self.labelGameDescription.text = String("Opponent: \(label)")
        }
    }
    
    func setGuessWord(guess: String)
    {
        DispatchQueue.main.async {
            self.labelYourGuessWord.text = String("My guess word: \(guess)")
        }
    }
    
    func setCurrentTurn(turn: UInt, myTurn: Bool)
    {
        DispatchQueue.main.async {
            self.labelTurn.text = String("Turn: \(turn)")
            
            if myTurn
            {
                self.buttonGuess.isEnabled = true
                self.labelStatus.text = String("It's your turn")
                self.labelStatus.textColor = .green
            }
            else
            {
                self.buttonGuess.isEnabled = false
                self.labelStatus.text = String("It's the opponents turn")
                self.labelStatus.textColor = .red
            }
        }
    }
    
    func updateLog(string: String)
    {
        DispatchQueue.main.async {
            self.labelLog.text = string
        }
    }
    
    func setActionDelegate(delegate: GameplayActionDelegate)
    {
        DispatchQueue.main.async {
            self.pincodeGuess.delegate = delegate
        }
    }
    
    func showPincode()
    {
        DispatchQueue.main.async {
            self.pincodeGuess.isHidden = false
            self.labelPincodeGuess.isHidden = false
            
            self.buttonCancel.isHidden = false
            
            self.hideBase()
        }
    }
    
    func hidePincode()
    {
        DispatchQueue.main.async {
            self.pincodeGuess.isHidden = true
            self.labelPincodeGuess.isHidden = true
            
            self.buttonCancel.isHidden = true
            
            self.pincodeGuess.text = ""
            
            self.showBase()
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
            self.labelConnectionStatus.text = GameplayView.ALERT_MESSAGE_RECONNECTING
        }
    }
    
    func changeConnectionStatusToReconnected()
    {
        DispatchQueue.main.async {
            self.layoutConnectionStatus.isHidden = false
            self.layoutConnectionStatus.backgroundColor = .green
            self.labelConnectionStatus.text = GameplayView.ALERT_MESSAGE_RECONNECTED
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) {
                if !self.layoutConnectionStatus.isHidden && self.labelConnectionStatus.text == GameplayView.ALERT_MESSAGE_RECONNECTED
                {
                    self.hideConnectionStatus()
                }
            }
        }
    }
    
    func showChat()
    {
        DispatchQueue.main.async {
            self.labelChat.isHidden = false
            self.fieldChat.isHidden = false
            
            self.buttonCancel.isHidden = false
            
            self.hideBase()
        }
    }
    
    func hideChat()
    {
        DispatchQueue.main.async {
            self.labelChat.isHidden = true
            self.fieldChat.isHidden = true
            
            self.buttonCancel.isHidden = true
            
            self.fieldChat.text = ""
            
            self.showBase()
        }
    }
    
    func showVictoryScreen(opponentGuessWord guessWord: String)
    {
        DispatchQueue.main.async {
            self.layoutOutcomeScreen.isHidden = false
            self.layoutOutcomeScreen.isUserInteractionEnabled = true
            self.layoutOutcomeScreen.backgroundColor = .green
            self.layoutOutcomeScreen.alpha = 0
            
            self.labelOutcome.isHidden = false
            self.labelOutcome.text = "YOU WIN!\nYou guessed \(guessWord)"
            self.labelOutcome.tintColor = .white
            
            UIView.animate(withDuration: 1.0, animations: {
                self.layoutOutcomeScreen.alpha = 1.0
            })
        }
    }
    
    func showDefeatScreen(myGuessWord guessWord: String)
    {
        DispatchQueue.main.async {
            self.layoutOutcomeScreen.isHidden = false
            self.layoutOutcomeScreen.isUserInteractionEnabled = true
            self.layoutOutcomeScreen.backgroundColor = .red
            self.layoutOutcomeScreen.alpha = 0
            
            self.labelOutcome.isHidden = false
            self.labelOutcome.text = "YOU LOSE!\nOpponent guessed \(guessWord)"
            self.labelOutcome.tintColor = .white
            
            UIView.animate(withDuration: 1.0, animations: {
                self.layoutOutcomeScreen.alpha = 1.0
            })
        }
    }
}

extension GameplayView
{
    @objc func actionGuess(_ sender: Any)
    {
        guard !self.buttonGuess.isHidden else {
            return
        }
        
        DispatchQueue.main.async {
            self.showPincode()
        }
    }
    
    @objc func actionChat(_ sender: Any)
    {
        guard !self.buttonChat.isHidden else {
            return
        }
        
        DispatchQueue.main.async {
            self.showChat()
        }
    }
    
    @objc func actionCancel(_ sender: Any)
    {
        guard !self.buttonCancel.isHidden else {
            return
        }
        
        DispatchQueue.main.async {
            self.hideChat()
            self.hidePincode()
        }
    }
    
    @objc func actionLeaveOutcomeScreen(_ sender: Any)
    {
        delegate?.leaveOutcomeScreen()
    }
}

extension GameplayView : UITextFieldDelegate
{
    func textFieldShouldReturn(_ textField: UITextField) -> Bool
    {
        guard !fieldChat.isHidden else {
            return true
        }
        
        if let text = textField.text
        {
            delegate?.chat(message: text)
        }
        
        self.hideChat()
        
        return true
    }
}

extension GameplayView
{
    class func create(owner: Any) -> GameplayView?
    {
        let bundle = Bundle.main
        let nibName = String(describing: GameplayView.self)
        let nib = UINib(nibName: nibName, bundle: bundle)
        
        return nib.instantiate(withOwner: owner, options: nil).first as? GameplayView
    }
}
