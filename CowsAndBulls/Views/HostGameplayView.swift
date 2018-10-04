//
//  HostGameplayView.swift
//  CowsAndBulls
//
//  Created by Kristiyan Butev on 2.10.18.
//  Copyright © 2018 Kristiyan Butev. All rights reserved.
//

import UIKit

protocol HostGameplayViewDelegate : class
{
    func connectionFailure(errorMessage: String)
}

protocol HostGameplayActionDelegate : class
{
    
}

class HostGameplayView : UIView
{
    weak var delegate : HostGameplayActionDelegate?
    
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
        
    }
}

extension HostGameplayView
{
    class func create(owner: Any) -> HostGameplayView?
    {
        let bundle = Bundle.main
        let nibName = String(describing: HostGameplayView.self)
        let nib = UINib(nibName: nibName, bundle: bundle)
        
        return nib.instantiate(withOwner: owner, options: nil).first as? HostGameplayView
    }
}
