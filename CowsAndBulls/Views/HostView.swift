//
//  HostView.swift
//  CowsAndBulls
//
//  Created by Kristiyan Butev on 2.10.18.
//  Copyright © 2018 Kristiyan Butev. All rights reserved.
//

import UIKit

protocol HostViewDelegate : class
{
    func connectionBegin()
    func connectionSuccessful(communicator: CommunicatorHost?, initialData: CommunicatorInitialConnection)
    func connectionFailure(errorMessage: String)
}

protocol HostActionDelegate : class
{
    
}

class HostView : UIView
{
    weak var delegate : HostActionDelegate?
    
    @IBOutlet private weak var labelDescription: UILabel!
    @IBOutlet private weak var labelYourIP: UILabel!
    
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
        
        labelDescription.translatesAutoresizingMaskIntoConstraints = false
        labelDescription.topAnchor.constraint(equalTo: guide.topAnchor, constant: 50.0).isActive = true
        labelDescription.centerXAnchor.constraint(equalTo: guide.centerXAnchor).isActive = true
        
        labelYourIP.translatesAutoresizingMaskIntoConstraints = false
        labelYourIP.topAnchor.constraint(equalTo: labelDescription.bottomAnchor, constant: 25.0).isActive = true
        labelYourIP.centerXAnchor.constraint(equalTo: guide.centerXAnchor).isActive = true
    }
}

extension HostView
{
    func beginConnecting()
    {
        DispatchQueue.main.async {
        }
    }
    
    func stopConnecting()
    {
        DispatchQueue.main.async {
        }
    }
    
    func setYourIP(address: String)
    {
        DispatchQueue.main.async {
            self.labelYourIP.text = String("Your IP is \(address)")
        }
    }
}

extension HostView
{
    class func create(owner: Any) -> HostView?
    {
        let bundle = Bundle.main
        let nibName = String(describing: HostView.self)
        let nib = UINib(nibName: nibName, bundle: bundle)
        
        return nib.instantiate(withOwner: owner, options: nil).first as? HostView
    }
}
