//
//  JoinView.swift
//  CowsAndBulls
//
//  Created by Kristiyan Butev on 2.10.18.
//  Copyright © 2018 Kristiyan Butev. All rights reserved.
//

import UIKit

protocol ClientViewDelegate : class
{
    func connectionBegin()
    func connectionSuccessful(communicator: CommunicatorClient?, initialData: CommunicatorInitialConnection)
    func connectionFailure(errorMessage: String)
}

protocol ClientActionDelegate : class
{
    func connect(hostAddress: String)
}

class ClientView : UIView
{
    weak var delegate : ClientActionDelegate?
    
    @IBOutlet private weak var labelHostAddress: UILabel!
    @IBOutlet private weak var fieldHostAddress: UITextField!
    @IBOutlet private weak var buttonConnect: UIButton!
    
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
        
        labelHostAddress.translatesAutoresizingMaskIntoConstraints = false
        labelHostAddress.topAnchor.constraint(equalTo: guide.topAnchor, constant: 50.0).isActive = true
        labelHostAddress.leadingAnchor.constraint(equalTo: guide.leadingAnchor, constant: 10.0).isActive = true
        
        fieldHostAddress.translatesAutoresizingMaskIntoConstraints = false
        fieldHostAddress.trailingAnchor.constraint(equalTo: guide.trailingAnchor, constant: 0.0).isActive = true
        fieldHostAddress.centerYAnchor.constraint(equalTo: labelHostAddress.centerYAnchor).isActive = true
        
        buttonConnect.translatesAutoresizingMaskIntoConstraints = false
        buttonConnect.topAnchor.constraint(equalTo: labelHostAddress.topAnchor, constant: 50.0).isActive = true
        buttonConnect.centerXAnchor.constraint(equalTo: guide.centerXAnchor).isActive = true
        buttonConnect.addTarget(self, action: #selector(actionConnect(_:)), for: .touchDown)
    }
}

extension ClientView
{
    func beginConnecting()
    {
        DispatchQueue.main.async {
            self.buttonConnect.isEnabled = false
            self.buttonConnect.setTitle("Connecting...", for: .disabled)
            
            self.fieldHostAddress.isEnabled = false
        }
    }
    
    func foundConnection()
    {
        DispatchQueue.main.async {
            self.buttonConnect.isEnabled = false
            self.buttonConnect.setTitle("Found host...", for: .disabled)
            
            self.fieldHostAddress.isEnabled = false
        }
    }
    
    func stopConnecting()
    {
        DispatchQueue.main.async {
            self.buttonConnect.isEnabled = true
            self.fieldHostAddress.isEnabled = true
        }
    }
}

extension ClientView
{
    @objc func actionConnect(_ sender: Any)
    {
        if let text = fieldHostAddress.text
        {
            delegate?.connect(hostAddress: text)
        }
    }
}

extension ClientView
{
    class func create(owner: Any) -> ClientView?
    {
        let bundle = Bundle.main
        let nibName = String(describing: ClientView.self)
        let nib = UINib(nibName: nibName, bundle: bundle)
        
        return nib.instantiate(withOwner: owner, options: nil).first as? ClientView
    }
}
