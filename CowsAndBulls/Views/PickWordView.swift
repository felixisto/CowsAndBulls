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
    func connectionFailure(errorMessage: String)
    
    func setOpponentStatus(status: String)
    func updateEnterXCharacterWord(length: UInt)
    
    func play(communicator: Communicator?, withGuessWord guessWord: String)
}

protocol PickWordActionDelegate : PinCodeTextFieldDelegate
{
    
}

class PickWordView : UIView
{
    weak var delegate : PickWordActionDelegate?
    @IBOutlet private weak var labelTip: UILabel!
    @IBOutlet private weak var labelOpponentStatus: UILabel!
    @IBOutlet private weak var pincodeGuessWord: PinCodeTextField!
    
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
        
        labelTip.translatesAutoresizingMaskIntoConstraints = false
        labelTip.topAnchor.constraint(equalTo: guide.topAnchor, constant: 10.0).isActive = true
        labelTip.centerXAnchor.constraint(equalTo: guide.centerXAnchor).isActive = true
        labelTip.textAlignment = .center
        
        pincodeGuessWord.translatesAutoresizingMaskIntoConstraints = false
        pincodeGuessWord.topAnchor.constraint(equalTo: labelTip.bottomAnchor, constant: 10.0).isActive = true
        pincodeGuessWord.centerXAnchor.constraint(equalTo: guide.centerXAnchor).isActive = true
        pincodeGuessWord.widthAnchor.constraint(equalTo: guide.widthAnchor, multiplier: 1.0).isActive = true
        pincodeGuessWord.heightAnchor.constraint(equalToConstant: 128.0).isActive = true
        pincodeGuessWord.allowedCharacterSet = CharacterSet.decimalDigits
        
        labelOpponentStatus.translatesAutoresizingMaskIntoConstraints = false
        labelOpponentStatus.topAnchor.constraint(equalTo: pincodeGuessWord.bottomAnchor, constant: 10.0).isActive = true
        labelOpponentStatus.centerXAnchor.constraint(equalTo: guide.centerXAnchor).isActive = true
        labelOpponentStatus.textAlignment = .center
        
    }
}

extension PickWordView
{
    func setNumberOfCharacter(length: UInt)
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
    
    func setActionDelegate(delegate: PinCodeTextFieldDelegate?)
    {
        DispatchQueue.main.async {
            self.pincodeGuessWord.delegate = delegate
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
