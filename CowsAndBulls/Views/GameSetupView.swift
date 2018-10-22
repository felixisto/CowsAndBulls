//
//  GameSetupView.swift
//  CowsAndBulls
//
//  Created by Kristiyan Butev on 2.10.18.
//  Copyright © 2018 Kristiyan Butev. All rights reserved.
//

import UIKit

protocol GameSetupViewDelegate : class
{
    func updateNumberOfCharactersPicker(dataSource: GameSetupWordLengthPickerViewDataSource?, delegate: GameSetupWordLengthPickerViewDelegate?)
    func updateTurnToGoPicker(dataSource: GameSetupTurnPickerViewDataSource?, delegate: GameSetupTurnPickerViewDelegate?)
    
    func updateConnectionData(playerAddress: String, playerName: String, playerColor: UIColor)
    func connectionFailure()
    func connectionFailure(errorMessage: String)
    
    func updateOpponentPlaySetup(guessWordLength: UInt, turnToGo: String)
    func playSetupMismatch()
    func playSetupMatch()
    
    func goToPickWordScreen(communicator: Communicator?, connectionData: CommunicatorInitialConnection, guessWordLength: UInt, turnToGo: GameTurn)
    
    func lostConnectingAttemptingToReconnect()
    func reconnect()
}

protocol GameSetupActionDelegate : class
{
    func didSelectGuessWordCharacterCount(number: UInt)
    func didSelectTurnToGo(turnToGo: String)
}

class GameSetupWordLengthPickerViewDataSource : NSObject, UIPickerViewDataSource
{
    private let values : [UInt]
    
    init(minNumber: UInt, maxNumber: UInt)
    {
        var numbers : [UInt] = []
        
        for e in minNumber...maxNumber
        {
            numbers.append(UInt(e))
        }
        
        self.values = numbers
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int
    {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int
    {
        return values.count
    }
}

class GameSetupTurnPickerViewDataSource : NSObject, UIPickerViewDataSource
{
    private let values : [String]
    
    init(values: [String])
    {
        self.values = values
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int
    {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int
    {
        return values.count
    }
}

class GameSetupWordLengthPickerViewDelegate : NSObject, UIPickerViewDelegate
{
    private let values : [UInt]
    private let actionDelegate: GameSetupActionDelegate?
    
    init(minNumber: UInt, maxNumber: UInt, actionDelegate: GameSetupActionDelegate?)
    {
        var numbers : [UInt] = []
        
        for e in minNumber...maxNumber
        {
            numbers.append(UInt(e))
        }
        
        self.values = numbers
        self.actionDelegate = actionDelegate
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String?
    {
        return String(values[row])
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int)
    {
        if (0..<values.count).contains(row)
        {
            actionDelegate?.didSelectGuessWordCharacterCount(number: values[row])
        }
    }
}

class GameSetupTurnPickerViewDelegate : NSObject, UIPickerViewDelegate
{
    private let values : [String]
    private let actionDelegate: GameSetupActionDelegate?
    
    init(values: [String], actionDelegate: GameSetupActionDelegate?)
    {
        self.values = values
        self.actionDelegate = actionDelegate
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String?
    {
        return String(values[row])
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int)
    {
        if (0..<values.count).contains(row)
        {
            actionDelegate?.didSelectTurnToGo(turnToGo: values[row])
        }
    }
}

class GameSetupView : UIView
{
    static let ALERT_MESSAGE_RECONNECTING = "Lost connection. Reconnecting..."
    static let ALERT_MESSAGE_RECONNECTED = "Reconnected!"
    
    weak var delegate : GameSetupActionDelegate?
    
    @IBOutlet private weak var labelInfo: UILabel!
    @IBOutlet private weak var labelTip: UILabel!
    @IBOutlet private weak var pickerNumberOfCharacters: UIPickerView!
    @IBOutlet private weak var labelWhoGoesFirst: UILabel!
    @IBOutlet private weak var pickerTurn: UIPickerView!
    @IBOutlet private weak var labelOpponentStatus: UILabel!
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
        labelInfo.widthAnchor.constraint(equalTo: guide.widthAnchor, constant: 0.8).isActive = true
        labelInfo.textAlignment = .center
        labelInfo.numberOfLines = 2
        
        labelTip.translatesAutoresizingMaskIntoConstraints = false
        labelTip.topAnchor.constraint(equalTo: labelInfo.bottomAnchor, constant: 40.0).isActive = true
        labelTip.centerXAnchor.constraint(equalTo: guide.centerXAnchor).isActive = true
        labelTip.widthAnchor.constraint(equalTo: guide.widthAnchor, constant: 1.0).isActive = true
        labelTip.textAlignment = .center
        
        pickerNumberOfCharacters.translatesAutoresizingMaskIntoConstraints = false
        pickerNumberOfCharacters.topAnchor.constraint(equalTo: labelTip.bottomAnchor, constant: 0.0).isActive = true
        pickerNumberOfCharacters.heightAnchor.constraint(equalToConstant: 128.0).isActive = true
        pickerNumberOfCharacters.centerXAnchor.constraint(equalTo: guide.centerXAnchor).isActive = true
        
        labelWhoGoesFirst.translatesAutoresizingMaskIntoConstraints = false
        labelWhoGoesFirst.topAnchor.constraint(equalTo: pickerNumberOfCharacters.bottomAnchor, constant: 40.0).isActive = true
        labelWhoGoesFirst.centerXAnchor.constraint(equalTo: guide.centerXAnchor).isActive = true
        labelWhoGoesFirst.widthAnchor.constraint(equalTo: guide.widthAnchor, constant: 1.0).isActive = true
        labelWhoGoesFirst.textAlignment = .center
        
        pickerTurn.translatesAutoresizingMaskIntoConstraints = false
        pickerTurn.topAnchor.constraint(equalTo: labelWhoGoesFirst.bottomAnchor, constant: 0.0).isActive = true
        pickerTurn.heightAnchor.constraint(equalToConstant: 128.0).isActive = true
        pickerTurn.centerXAnchor.constraint(equalTo: guide.centerXAnchor).isActive = true
        
        labelOpponentStatus.translatesAutoresizingMaskIntoConstraints = false
        labelOpponentStatus.bottomAnchor.constraint(equalTo: guide.bottomAnchor, constant: 0.0).isActive = true
        labelOpponentStatus.widthAnchor.constraint(equalTo: guide.widthAnchor, multiplier: 0.9).isActive = true
        labelOpponentStatus.centerXAnchor.constraint(equalTo: guide.centerXAnchor).isActive = true
        labelOpponentStatus.textAlignment = .center
        labelOpponentStatus.numberOfLines = 2
        
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
extension GameSetupView
{
    func updateConnectionData(playerAddress: String, playerName: String, playerColor: UIColor)
    {
        DispatchQueue.main.async {
            self.labelInfo.text = String("Opponent: \(playerName) (\(playerAddress))")
        }
    }
    
    func updateNumberOfCharactersPicker(dataSource: GameSetupWordLengthPickerViewDataSource?, delegate: GameSetupWordLengthPickerViewDelegate?)
    {
        DispatchQueue.main.async {
            self.pickerNumberOfCharacters.dataSource = dataSource
            self.pickerNumberOfCharacters.delegate = delegate
            self.pickerNumberOfCharacters.reloadAllComponents()
        }
    }
    
    func updateTurnToGoPicker(dataSource: GameSetupTurnPickerViewDataSource?, delegate: GameSetupTurnPickerViewDelegate?)
    {
        DispatchQueue.main.async {
            self.pickerTurn.dataSource = dataSource
            self.pickerTurn.delegate = delegate
            self.pickerTurn.reloadAllComponents()
        }
    }
    
    func updateOpponentStatus(guessWordLength: UInt, turnToGo: String)
    {
        DispatchQueue.main.async {
            self.labelOpponentStatus.text = String("Opponent wants \(guessWordLength) digit guess words and wants \(turnToGo) turn")
        }
    }
    
    func enableUserInteraction()
    {
        DispatchQueue.main.async {
            self.pickerNumberOfCharacters.isUserInteractionEnabled = true
            self.pickerTurn.isUserInteractionEnabled = true
        }
    }
    
    func disableUserInteraction()
    {
        DispatchQueue.main.async {
            self.pickerNumberOfCharacters.isUserInteractionEnabled = false
            self.pickerTurn.isUserInteractionEnabled = false
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
            self.labelConnectionStatus.text = GameSetupView.ALERT_MESSAGE_RECONNECTING
        }
    }
    
    func changeConnectionStatusToReconnected()
    {
        DispatchQueue.main.async {
            self.layoutConnectionStatus.isHidden = false
            self.layoutConnectionStatus.backgroundColor = .green
            self.labelConnectionStatus.text = GameSetupView.ALERT_MESSAGE_RECONNECTED
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) {
                if !self.layoutConnectionStatus.isHidden && self.labelConnectionStatus.text == GameSetupView.ALERT_MESSAGE_RECONNECTED
                {
                    self.hideConnectionStatus()
                }
            }
        }
    }
}

extension GameSetupView
{
    class func create(owner: Any) -> GameSetupView?
    {
        let bundle = Bundle.main
        let nibName = String(describing: GameSetupView.self)
        let nib = UINib(nibName: nibName, bundle: bundle)
        
        return nib.instantiate(withOwner: owner, options: nil).first as? GameSetupView
    }
}
