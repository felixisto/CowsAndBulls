//
//  JoinView.swift
//  CowsAndBulls
//
//  Created by Kristiyan Butev on 2.10.18.
//  Copyright © 2018 Kristiyan Butev. All rights reserved.
//

import UIKit

protocol JoinViewDelegate : class
{
    func connectionSuccessful(communicator: Communicator?)
    func connectionFailure(errorMessage: String)
}

protocol JoinActionDelegate : class
{
    func connect(hostAddress: String)
}

class JoinView : UIView
{
    weak var delegate : JoinActionDelegate?
    
    @IBOutlet weak var labelHostAddress: UILabel!
    @IBOutlet weak var fieldHostAddress: UITextField!
    @IBOutlet weak var buttonConnect: UIButton!
    
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
        labelHostAddress.topAnchor.constraint(equalTo: guide.topAnchor, constant: 10.0).isActive = true
        labelHostAddress.leadingAnchor.constraint(equalTo: guide.leadingAnchor, constant: 10.0).isActive = true
        
        fieldHostAddress.translatesAutoresizingMaskIntoConstraints = false
        fieldHostAddress.topAnchor.constraint(equalTo: guide.topAnchor).isActive = true
        fieldHostAddress.trailingAnchor.constraint(equalTo: guide.trailingAnchor, constant: -10.0).isActive = true
        
        buttonConnect.translatesAutoresizingMaskIntoConstraints = false
        buttonConnect.topAnchor.constraint(equalTo: labelHostAddress.topAnchor, constant: 40.0).isActive = true
        buttonConnect.centerXAnchor.constraint(equalTo: guide.centerXAnchor).isActive = true
        buttonConnect.addTarget(self, action: #selector(actionConnect(_:)), for: .touchDown)
    }
}

extension JoinView
{
    func beginConnecting()
    {
        DispatchQueue.main.async {
            self.buttonConnect.isEnabled = false
            self.buttonConnect.setTitle("Connecting...", for: .disabled)
        }
    }
    
    func stopConnecting()
    {
        DispatchQueue.main.async {
            self.buttonConnect.isEnabled = true
        }
    }
}

extension JoinView
{
    @objc func actionConnect(_ sender: Any)
    {
        if let text = fieldHostAddress.text
        {
            delegate?.connect(hostAddress: text)
        }
    }
}

extension JoinView
{
    class func create(owner: Any) -> JoinView?
    {
        let bundle = Bundle.main
        let nibName = String(describing: JoinView.self)
        let nib = UINib(nibName: nibName, bundle: bundle)
        
        return nib.instantiate(withOwner: owner, options: nil).first as? JoinView
    }
}
