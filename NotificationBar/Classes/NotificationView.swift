//
//  NotificationView.swift
//  Pods
//
//  Created by Giáp Trần on 1/4/17.
//
//

import UIKit

@objc
public enum NotificationStyle: Int {
    case alert = 0, banner
}

protocol NotificationDelegate: class {
    
    func didSelectMessage()
    
    func didSendMessage(_ text: String)
    
}

class NotificationView: UIView {

    // MARK: Property
    
    @IBOutlet fileprivate var view: UIView?
    @IBOutlet weak var appImageView: UIImageView!
    @IBOutlet weak var appTitleLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var messageTitleLabel: UILabel!
    @IBOutlet weak var messageBodyLabel: UILabel!
    @IBOutlet weak var notificationStyleIndicator: UIView!
    @IBOutlet weak var visualEffectView: UIVisualEffectView!
    @IBOutlet weak var replyTextField: UITextField!
    @IBOutlet weak var sendButton: UIButton!
    @IBOutlet weak var inputBottomMarginConstraint: NSLayoutConstraint!
   
    internal static var minWidth: CGFloat {
        if let frame = UIApplication.shared.keyWindow?.bounds {
            return frame.width > 575 ? 575 : frame.width
        }
        return 575
    }
    
    internal static let minHeight: CGFloat = 78
    internal var style: NotificationStyle = .alert
    internal var timeOutDefault: Double = 3
    internal var isExpanding: Bool = false
    internal var isHiding: Bool = false
    internal weak var delegate: NotificationDelegate?
    
    // MARK: Constructor
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        commonInit()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    deinit {
        endEditing(true)
        NotificationCenter.default.removeObserver(self)
    }
    
    // MARK: Action
    
    @IBAction func panAction(_ gestureRecognizer: UIPanGestureRecognizer) {
        if isHiding { return }
        
        switch gestureRecognizer.state {
        case .changed:
            let translation = gestureRecognizer.translation(in: self)
            center = CGPoint(x: center.x, y: center.y + translation.y)
            gestureRecognizer.setTranslation(CGPoint(x: 0,y: 0), in: self)
            
            if frame.origin.y > 20, !isExpanding, style != .alert {
                isExpanding = true
                UIView.animate(withDuration: 0.33, delay: 0.0, options: .curveEaseIn, animations: { [weak self] _ in
                    guard let sSelf = self else { return }
                    
                    let height = sSelf.frame.height + 42
                    sSelf.inputBottomMarginConstraint.constant = 3
                    sSelf.frame = CGRect(
                        x       : sSelf.frame.origin.x,
                        y       : 0,
                        width   : sSelf.frame.width,
                        height  : height
                    )
                    sSelf.layoutIfNeeded()
                }, completion: { [weak self] _ in
                    guard let sSelf = self else { return }
                        
                    sSelf.replyTextField.becomeFirstResponder()
                })
            }
        case .ended:
            if frame.origin.y < -10 {
                hideNotification()
            } else {
                UIView.animate(withDuration: 0.33, animations: { [weak self] _ in
                    guard let sSelf = self else { return }
                    
                    sSelf.frame.origin = CGPoint(x: sSelf.frame.origin.x, y: 0)
                })
            }
        default:
            break
        }
    }
    
    @IBAction func tapAction(_ sender: Any) {
        if isHiding { return }
        
        delegate?.didSelectMessage()
        hideNotification()
    }
    
    @IBAction func sendAction(_ sender: Any) {
        delegate?.didSendMessage(replyTextField.text!)
        hideNotification()
    }
    
    @IBAction func textFieldDidChange(_ sender: Any) {
        sendButton.isEnabled = !replyTextField.text!.isEmpty
        replyTextField.enablesReturnKeyAutomatically = sendButton.isEnabled
    }
    
    // MARK: Internal method
    
    internal func setStyle(_ style: NotificationStyle, title: String, body: String) {
        self.style = style
        notificationStyleIndicator.isHidden = style == .alert
        messageTitleLabel.text = title
        messageBodyLabel.text = body
        messageBodyLabel.sizeToFit()
 
        showNotification()
        
        let time = DispatchTime.now() + Double(Int64(timeOutDefault * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC)
        DispatchQueue.main.asyncAfter(deadline: time, execute: { [weak self] _ in
            guard let sSelf = self else { return }
            
            if !sSelf.isExpanding, !sSelf.isHiding {
                sSelf.hideNotification()
            }
        })
    }
    
    internal func setAppInfo(appName: String?, appIcon: String?) {
        appTitleLabel.text = appName
        
        if let appIcon = appIcon {
            appImageView.image = UIImage(named: appIcon)
        } else {
            appImageView.layer.borderColor = UIColor.gray.cgColor
            appImageView.layer.borderWidth = 1.0
        }
    }
    
    internal func showNotification() {
        guard let window = UIApplication.shared.keyWindow else { return }
        let width = NotificationView.minWidth
        let height = NotificationView.minHeight + messageBodyLabel.bounds.height
        frame = CGRect(
            x       : (window.frame.width - width) / 2,
            y       : -height,
            width   : width,
            height  : 0
        )
        UIView.animate(withDuration: 0.33, delay: 0.0, options: .curveEaseIn, animations: { [weak self] _ in
            guard let sSelf = self else { return }
            
            let height = NotificationView.minHeight + sSelf.messageBodyLabel.bounds.height + 10
            sSelf.frame = CGRect(
                x       : (window.frame.width - width) / 2,
                y       : 0,
                width   : width,
                height  : height
            )
            sSelf.layoutIfNeeded()
        })
        window.windowLevel = UIWindowLevelStatusBar + 1
        window.addSubview(self)
    }
    
    internal func hideNotification(animated: Bool = true) {
        isHiding = true
        guard let window = UIApplication.shared.keyWindow else { return }
        if animated {
            UIView.animate(withDuration: 0.33, delay: 0.0, options: .curveEaseOut, animations: { [weak self] _ in
                guard let sSelf = self else { return }
                
                sSelf.frame.origin = CGPoint(x: sSelf.frame.origin.x, y: -sSelf.frame.height)
                }, completion: { [weak self] _ in
                    guard let sSelf = self else { return }
                    
                    sSelf.removeFromSuperview()
                    sSelf.isExpanding = false
                    sSelf.isHiding = false
                    window.windowLevel = 0.0
            })
        } else {
            removeFromSuperview()
            isExpanding = false
            isHiding = false
        }
    }
    
    // MARK: Private method
    
    private func commonInit() {
        Bundle(for: NotificationView.self).loadNibNamed("NotificationView", owner:self, options:nil)
        guard let content = view else { return }
        
        content.frame = bounds
        content.autoresizingMask = [.flexibleHeight, .flexibleWidth]
        addSubview(content)
        
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowOffset = CGSize(width: 1, height: 1)
        layer.shadowRadius = 7
        layer.shadowOpacity = 0.5
        
        replyTextField.delegate = self
        
        appImageView.layer.cornerRadius = 5.0
        appImageView.clipsToBounds = true
        visualEffectView.layer.cornerRadius = 14.0
        visualEffectView.clipsToBounds = true
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(orientationChangeNotification(_:)),
            name    : .UIDeviceOrientationDidChange,
            object  : nil
        )
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(stateChangeNotification(_:)),
            name    : .UIApplicationWillResignActive,
            object  : nil
        )
    }
    
    private func updateFrame() {
        if let window = UIApplication.shared.keyWindow {
            let width = NotificationView.minWidth
            let height = bounds.height
            self.frame = CGRect(
                x       : (window.frame.width - width) / 2,
                y       : 0,
                width   : width,
                height  : height
            )
            layoutIfNeeded()
            window.windowLevel = 0.0
        }
    }
    
    @objc
    private func orientationChangeNotification(_ notification: Notification) {
        updateFrame()
    }
    
    @objc
    private func stateChangeNotification(_ notification: Notification) {
        hideNotification()
    }

}

// MARK: UITextFieldDelegate implementation

extension NotificationView: UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        
        delegate?.didSendMessage(replyTextField.text!)
        hideNotification()
        return true
    }
    
}
