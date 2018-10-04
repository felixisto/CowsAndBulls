//
//  PickRoleView.swift
//  CowsAndBulls
//
//  Created by Kristiyan Butev on 2.10.18.
//  Copyright © 2018 Kristiyan Butev. All rights reserved.
//

import UIKit

protocol PickRoleViewDelegate : class
{
    func connectionFailure(errorMessage: String)
}

protocol PickRoleActionDelegate : class
{
    
}

class PickRoleView : UIView
{
    weak var delegate : PickRoleActionDelegate?
    
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

extension PickRoleView
{
    class func create(owner: Any) -> PickRoleView?
    {
        let bundle = Bundle.main
        let nibName = String(describing: PickRoleView.self)
        let nib = UINib(nibName: nibName, bundle: bundle)
        
        return nib.instantiate(withOwner: owner, options: nil).first as? PickRoleView
    }
}
