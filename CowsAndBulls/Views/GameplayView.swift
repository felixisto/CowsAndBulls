//
//  GameplayView.swift
//  CowsAndBulls
//
//  Created by Kristiyan Butev on 2.10.18.
//  Copyright © 2018 Kristiyan Butev. All rights reserved.
//

import UIKit

protocol GameplayViewDelegate : class
{
    func connectionFailure(errorMessage: String)
}

protocol GameplayActionDelegate : class
{
    
}

class GameplayView : UIView
{
    weak var delegate : GameplayActionDelegate?
    
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

extension GameplayView
{
    class func create(owner: Any) -> GameplayView?
    {
        let bundle = Bundle.main
        let nibName = String(describing: GameplayView.self)
        let nib = UINib(nibName: nibName, bundle: bundle)
        
        return nib.instantiate(withOwner: owner, options: nil).first as? GameplayView
    }
}
