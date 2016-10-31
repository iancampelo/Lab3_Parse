//
//  ChatViewController.swift
//  Lab3_Parse
//
//  Created by Ian Campelo on 10/29/16.
//  Copyright © 2016 Ian Campelo. All rights reserved.
//

import UIKit
import Parse

@objc protocol ChatViewControllerDelegate{
    @objc optional func chatViewController(chatViewController: ChatViewController)
}

class ChatViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    @IBOutlet weak var tableView: UITableView!
    
    @IBOutlet weak var messageText: UITextField!
    
    var messages: [PFObject]!
    var timer: Timer?
    
    weak var delegate: ChatViewControllerDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 120
        
        timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(self.onTimer), userInfo: nil, repeats: true)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        timer!.invalidate()
        timer = nil
    }
    
    func onTimer(){
        let query = PFQuery(className: "Message")
        
        query.whereKey("text", notEqualTo: "")
        query.includeKey("user")
        query.order(byDescending: "createdAt")
        query.findObjectsInBackground(){
            (success, error) in
            if let error = error{
                let errorString = error as NSError
                self.showModal(isErrorMsg: true, msg: errorString.userInfo["error"] as! String)
            }else{
                //self.showModal(isErrorMsg: false, msg: "Message sent!")
                if let success = success{
                    self.messages = success
                    for one in self.messages{
                        NSLog("-->Msg: \(one["text"]), -->user: \(one["user"])")
                    }
                    self.tableView.reloadData()
                }
            }
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let messages = messages{
            self.tableView.alpha = 1;
            return messages.count
        }
        self.tableView.alpha = 0;
        return 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "MessageCell", for: indexPath as IndexPath) as! MessageCell
        
        if let text = messages![indexPath.row]["text"]{
            cell.messageLabel.text = "\(text)"
        }else{
            cell.messageLabel.text = "nil"
        }
        
        if let user = messages![indexPath.row]["user"]{
            cell.sentByLabel.text = "\((user as! PFUser).username!) said:"
        }else{
            cell.sentByLabel.text = ""
        }
        
        
        return cell
    }
    
    @IBAction func btnSendMsgClick(_ sender: UIButton) {
        if let text = messageText.text {
            let message = PFObject(className: "Message")
            message["user"] = PFUser.current()
            message["text"] = text
            message.saveInBackground(){
                (success, error) in
                if let error = error{
                    let errorString = error as NSError
                    self.showModal(isErrorMsg: true, msg: errorString.userInfo["error"] as! String)
                }else{
                    self.showModal(isErrorMsg: false, msg: "Message sent!")
                    self.messageText.text = ""
                    NSLog("Message saved. Message: \(text)")
                }
            }
        }else{
            showModal(isErrorMsg: true, msg: "You need to say something ;)")
        }
    }
    
    @IBAction func logoutClick(_ sender: UIBarButtonItem) {
        PFUser.logOut()
        dismiss(animated: true, completion: nil)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        
    }
    
    func showModal(isErrorMsg: Bool ,msg: String){
        let title = isErrorMsg ? "Error" : "Alert"
        
        let alertController = UIAlertController(title: title, message: msg, preferredStyle: .alert)
        
        // create an OK action
        let OKAction = UIAlertAction(title: "OK", style: .default) { (action) in
            // handle response here.
        }
        // add the OK action to the alert controller
        alertController.addAction(OKAction)
        
        present(alertController, animated: true) {
            // optional code for what happens after the alert controller has finished presenting
        }
    }


}
