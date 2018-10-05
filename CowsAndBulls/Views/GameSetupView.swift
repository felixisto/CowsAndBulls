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
    func updateNumberOfCharactersPicker(dataSource: GameSetupPickerViewDataSource?, delegate: GameSetupPickerViewDelegate?)
    func updateConnectionData(playerAddress: String, playerName: String, playerColor: UIColor)
    func connectionFailure(errorMessage: String)
    
    func opponentDidSelectGuessWordCharacterCount(number: UInt)
    func guessWordCharacterCountMismatch()
    func guessWordCharacterCountMatch()
    
    func goToPickWord(communicator: Communicator?, withGuessWordLength guessWordLength: UInt)
}

protocol GameSetupActionDelegate : class
{
    func didSelectGuessWordCharacterCount(number: UInt)
}

class GameSetupPickerViewDataSource : NSObject, UIPickerViewDataSource
{
    private let numbers : [UInt]
    
    init(minNumber: UInt, maxNumber: UInt)
    {
        var numbers : [UInt] = []
        
        for e in minNumber...maxNumber
        {
            numbers.append(UInt(e))
        }
        
        self.numbers = numbers
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int
    {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int
    {
        return numbers.count
    }
}

class GameSetupPickerViewDelegate : NSObject, UIPickerViewDelegate
{
    private let numbers : [UInt]
    private let actionDelegate: GameSetupActionDelegate?
    
    init(minNumber: UInt, maxNumber: UInt, actionDelegate: GameSetupActionDelegate?)
    {
        var numbers : [UInt] = []
        
        for e in minNumber...maxNumber
        {
            numbers.append(UInt(e))
        }
        
        self.numbers = numbers
        self.actionDelegate = actionDelegate
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String?
    {
        return String(numbers[row])
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int)
    {
        if (0..<numbers.count).contains(row)
        {
            actionDelegate?.didSelectGuessWordCharacterCount(number: numbers[row])
        }
    }
}

class GameSetupView : UIView
{
    weak var delegate : GameSetupActionDelegate?
    
    @IBOutlet private weak var labelInfo: UILabel!
    @IBOutlet private weak var labelTip: UILabel!
    @IBOutlet private weak var pickerNumberOfCharacters: UIPickerView!
    @IBOutlet private weak var labelOpponentStatus: UILabel!
    
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
        
        labelOpponentStatus.translatesAutoresizingMaskIntoConstraints = false
        labelOpponentStatus.topAnchor.constraint(equalTo: pickerNumberOfCharacters.bottomAnchor, constant: 0.0).isActive = true
        labelOpponentStatus.centerXAnchor.constraint(equalTo: guide.centerXAnchor).isActive = true
        labelTip.textAlignment = .center
    }
}

extension GameSetupView
{
    func updateConnectionData(playerAddress: String, playerName: String, playerColor: UIColor)
    {
        DispatchQueue.main.async {
            self.labelInfo.text = String("You are playing with \(playerName) (\(playerAddress))")
        }
    }
    
    func updateNumberOfCharactersPicker(dataSource: GameSetupPickerViewDataSource?, delegate: GameSetupPickerViewDelegate?)
    {
        DispatchQueue.main.async {
            self.pickerNumberOfCharacters.dataSource = dataSource
            self.pickerNumberOfCharacters.delegate = delegate
            self.pickerNumberOfCharacters.reloadAllComponents()
        }
    }
    
    func setOpponentGuessWordLength(length: UInt)
    {
        DispatchQueue.main.async {
            self.labelOpponentStatus.text = String("Opponent wants \(length) character guess words")
        }
    }
    
    func enableUserInteraction()
    {
        DispatchQueue.main.async {
            self.pickerNumberOfCharacters.isUserInteractionEnabled = true
        }
    }
    
    func disableUserInteraction()
    {
        DispatchQueue.main.async {
            self.pickerNumberOfCharacters.isUserInteractionEnabled = false
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
