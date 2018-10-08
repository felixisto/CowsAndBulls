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
    
    func lostConnectingAttemptingToReconnect()
    func reconnect()
}

protocol GameplayActionDelegate : class
{
    
}

class GameplayView : UIView
{
    static let ALERT_MESSAGE_RECONNECTING = "Lost connection. Reconnecting..."
    static let ALERT_MESSAGE_RECONNECTED = "Reconnected!"
    
    weak var delegate : GameplayActionDelegate?
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
        
        layoutConnectionStatus.translatesAutoresizingMaskIntoConstraints = false
        layoutConnectionStatus.bottomAnchor.constraint(equalTo: guide.bottomAnchor, constant: 0.0).isActive = true
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
extension GameplayView
{
    func hideConnectionStatus()
    {
        DispatchQueue.main.async {
            self.layoutConnectionStatus.isHidden = true
        }
    }
    
    func changeConnectionStatusToReconnecting()
    {
        DispatchQueue.main.async {
            self.layoutConnectionStatus.isHidden = false
            self.layoutConnectionStatus.backgroundColor = .orange
            self.labelConnectionStatus.text = GameplayView.ALERT_MESSAGE_RECONNECTING
        }
    }
    
    func changeConnectionStatusToReconnected()
    {
        DispatchQueue.main.async {
            self.layoutConnectionStatus.isHidden = false
            self.layoutConnectionStatus.backgroundColor = .green
            self.labelConnectionStatus.text = GameplayView.ALERT_MESSAGE_RECONNECTED
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) {
                if !self.layoutConnectionStatus.isHidden && self.labelConnectionStatus.text == GameplayView.ALERT_MESSAGE_RECONNECTED
                {
                    self.hideConnectionStatus()
                }
            }
        }
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
