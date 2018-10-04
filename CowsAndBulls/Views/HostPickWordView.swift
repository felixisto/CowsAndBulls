//
//  HostPickWordView.swift
//  CowsAndBulls
//
//  Created by Kristiyan Butev on 2.10.18.
//  Copyright © 2018 Kristiyan Butev. All rights reserved.
//

import UIKit

protocol HostPickWordViewDelegate : class
{
    func connectionFailure(errorMessage: String)
}

protocol HostPickWordActionDelegate : class
{
    
}

class HostPickWordView : UIView
{
    weak var delegate : HostPickWordActionDelegate?
    
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

extension HostPickWordView
{
    class func create(owner: Any) -> HostPickWordView?
    {
        let bundle = Bundle.main
        let nibName = String(describing: HostPickWordView.self)
        let nib = UINib(nibName: nibName, bundle: bundle)
        
        return nib.instantiate(withOwner: owner, options: nil).first as? HostPickWordView
    }
}
