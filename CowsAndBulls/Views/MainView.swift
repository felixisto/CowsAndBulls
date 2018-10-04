//
//  MainView.swift
//  CowsAndBulls
//
//  Created by Kristiyan Butev on 2.10.18.
//  Copyright © 2018 Kristiyan Butev. All rights reserved.
//

import UIKit

protocol MainViewDelegate : class
{
    
}

protocol MainActionDelegate : class
{
    func host()
    func join()
}

class MainView : UIView
{
    weak var delegate : MainActionDelegate?
    
    @IBOutlet weak var imageSpash: UIImageView!
    @IBOutlet weak var buttonHost: UIButton!
    @IBOutlet weak var buttonJoin: UIButton!
    
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
        
        imageSpash.translatesAutoresizingMaskIntoConstraints = false
        imageSpash.centerXAnchor.constraint(equalTo: guide.centerXAnchor).isActive = true
        imageSpash.centerYAnchor.constraint(equalTo: guide.centerYAnchor).isActive = true
        imageSpash.widthAnchor.constraint(equalTo: self.widthAnchor, multiplier: 1.0).isActive = true
        imageSpash.heightAnchor.constraint(equalTo: self.heightAnchor, multiplier: 1.0).isActive = true
        self.sendSubviewToBack(imageSpash)
        
        buttonHost.translatesAutoresizingMaskIntoConstraints = false
        buttonHost.centerYAnchor.constraint(equalTo: guide.centerYAnchor, constant: -50).isActive = true
        buttonHost.centerXAnchor.constraint(equalTo: guide.centerXAnchor).isActive = true
        buttonHost.widthAnchor.constraint(equalToConstant: 168).isActive = true
        buttonHost.addTarget(self, action: #selector(actionHost(_:)), for: .touchDown)
        
        buttonJoin.translatesAutoresizingMaskIntoConstraints = false
        buttonJoin.centerYAnchor.constraint(equalTo: guide.centerYAnchor, constant: 50).isActive = true
        buttonJoin.centerXAnchor.constraint(equalTo: guide.centerXAnchor).isActive = true
        buttonJoin.widthAnchor.constraint(equalToConstant: 168).isActive = true
        buttonJoin.addTarget(self, action: #selector(actionJoin(_:)), for: .touchDown)
    }
}

extension MainView
{
    @objc func actionHost(_ sender: Any)
    {
        delegate?.host()
    }
    
    @objc func actionJoin(_ sender: Any)
    {
        delegate?.join()
    }
}

extension MainView
{
    class func create(owner: Any) -> MainView?
    {
        let bundle = Bundle.main
        let nibName = String(describing: MainView.self)
        let nib = UINib(nibName: nibName, bundle: bundle)
        
        return nib.instantiate(withOwner: owner, options: nil).first as? MainView
    }
}
