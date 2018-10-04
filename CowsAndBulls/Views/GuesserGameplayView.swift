//
//  GuesserGameplayView.swift
//  CowsAndBulls
//
//  Created by Kristiyan Butev on 2.10.18.
//  Copyright © 2018 Kristiyan Butev. All rights reserved.
//

import UIKit

protocol GuesserGameplayViewDelegate : class
{
    func connectionFailure(errorMessage: String)
}

protocol GuesserGameplayActionDelegate : class
{
    
}

class GuesserGameplayView : UIView
{
    weak var delegate : GuesserGameplayActionDelegate?
    
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

extension GuesserGameplayView
{
    class func create(owner: Any) -> GuesserGameplayView?
    {
        let bundle = Bundle.main
        let nibName = String(describing: GuesserGameplayView.self)
        let nib = UINib(nibName: nibName, bundle: bundle)
        
        return nib.instantiate(withOwner: owner, options: nil).first as? GuesserGameplayView
    }
}
