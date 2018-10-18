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
    static let ALERT_MESSAGE_QUIT = "Opponent quit"
    static let ALERT_MESSAGE_DISCONNECTED = "Disconnected"
    
    weak var delegate : MainActionDelegate?
    
    @IBOutlet private weak var imageSpash: UIImageView!
    @IBOutlet private weak var buttonHost: UIButton!
    @IBOutlet private weak var buttonJoin: UIButton!
    @IBOutlet private weak var layoutConnectionStatus: UIView!
    @IBOutlet private weak var labelConnectionStatus: UILabel!
    
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
        imageSpash.centerXAnchor.constraint(equalTo: self.centerXAnchor).isActive = true
        imageSpash.centerYAnchor.constraint(equalTo: self.centerYAnchor).isActive = true
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
        
        layoutConnectionStatus.translatesAutoresizingMaskIntoConstraints = false
        layoutConnectionStatus.centerXAnchor.constraint(equalTo: guide.centerXAnchor).isActive = true
        layoutConnectionStatus.centerYAnchor.constraint(equalTo: guide.centerYAnchor).isActive = true
        layoutConnectionStatus.widthAnchor.constraint(equalTo: guide.widthAnchor, multiplier: 1.0).isActive = true
        layoutConnectionStatus.heightAnchor.constraint(equalToConstant: 32.0).isActive = true
        layoutConnectionStatus.isHidden = true
        
        labelConnectionStatus.translatesAutoresizingMaskIntoConstraints = false
        labelConnectionStatus.centerXAnchor.constraint(equalTo: layoutConnectionStatus.centerXAnchor).isActive = true
        labelConnectionStatus.centerYAnchor.constraint(equalTo: layoutConnectionStatus.centerYAnchor).isActive = true
        labelConnectionStatus.textAlignment = .center
    }
}

// Methods for updating the interface
extension MainView
{
    func hideConnectionStatus()
    {
        DispatchQueue.main.async {
            self.layoutConnectionStatus.isHidden = true
        }
    }
    
    func changeConnectionStatusToQuit()
    {
        DispatchQueue.main.async {
            self.layoutConnectionStatus.isHidden = false
            self.layoutConnectionStatus.backgroundColor = .orange
            self.labelConnectionStatus.text = MainView.ALERT_MESSAGE_QUIT
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) {
                self.hideConnectionStatus()
            }
        }
    }
    
    func changeConnectionStatusToDisconnected()
    {
        DispatchQueue.main.async {
            self.layoutConnectionStatus.isHidden = false
            self.layoutConnectionStatus.backgroundColor = .red
            self.labelConnectionStatus.text = MainView.ALERT_MESSAGE_DISCONNECTED
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) {
                self.hideConnectionStatus()
            }
        }
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
