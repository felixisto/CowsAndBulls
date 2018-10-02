//
//  GuesserPickWordView.swift
//  CowsAndBulls
//
//  Created by Kristiyan Butev on 2.10.18.
//  Copyright © 2018 Kristiyan Butev. All rights reserved.
//

import UIKit

protocol GuesserPickWordViewDelegate : class
{
    
}

protocol GuesserPickWordActionDelegate : class
{
    
}

class GuesserPickWordView : UIView
{
    weak var delegate : GuesserPickWordActionDelegate?
    
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

extension GuesserPickWordView
{
    class func create(owner: Any) -> GuesserPickWordView?
    {
        let bundle = Bundle.main
        let nibName = String(describing: GuesserPickWordView.self)
        let nib = UINib(nibName: nibName, bundle: bundle)
        
        return nib.instantiate(withOwner: owner, options: nil).first as? GuesserPickWordView
    }
}
