//
//  LoginViewController.swift
//  Lab3_Parse
//
//  Created by Ian Campelo on 10/29/16.
//  Copyright © 2016 Ian Campelo. All rights reserved.
//

import UIKit
import Parse

class LoginViewController: UIViewController, UITextFieldDelegate {
    @IBOutlet weak var emailText: UITextField!
    @IBOutlet weak var passwordText: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        emailText.delegate = self
        passwordText.delegate = self
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func emailEditingDidEnd(_ sender: UITextField) {
        if(isValidEmail(testStr: emailText.text!)){
            self.passwordText.becomeFirstResponder()
        }else{
            self.emailText.becomeFirstResponder()
            showModal(isErrorMsg: true, msg: "Invalid e-mail format")
        }
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
    
    func validateTexts() -> Bool{
        
        if(emailText.text == nil){
            return false
        }
        if(passwordText.text == nil){
            return false
        }
        return true
    }
    @IBAction func forgetPassClick(_ sender: UIButton) {
        if(emailText.text == nil){
            showModal(isErrorMsg: true, msg: "Email field are required")
        }
        else{
            
            PFUser.requestPasswordResetForEmail(inBackground: emailText.text!){
                (sucess, error) in
                if let error = error{
                    let errorString = error as NSError
                    self.showModal(isErrorMsg: true, msg: errorString.userInfo["error"] as! String)
                }else{
                    self.showModal(isErrorMsg: false, msg: "Email sent to \(self.emailText.text!)!")
                }
            }
        }
    }
    
    @IBAction func loginClick(_ sender: AnyObject) {
        if(validateTexts()){
            PFUser.logInWithUsername(inBackground: emailText.text!, password: passwordText.text!){
                (sucess, error) in
                if let error = error{
                    let errorString = error as NSError
                    self.showModal(isErrorMsg: true, msg: errorString.userInfo["error"] as! String)
                }else{
                    self.showModal(isErrorMsg: false, msg: "Logged in!")
                }
            }
        }else{
            showModal(isErrorMsg: true, msg: "All fields are required")
        }
    }
    
    @IBAction func signupClick(_ sender: AnyObject) {
        if(validateTexts()){
            let user = PFUser()
            
            user.email = emailText.text
            user.username = emailText.text
            user.password = passwordText.text
            
            //        // other fields can be set just like with PFObject
            //        user["phone"] = "415-392-0202"
            //
            
            user.signUpInBackground() {
                (succeeded, error) in
                
                if let error = error{
                    let errorString = error as NSError
                    // Show the errorString somewhere and let the user try again.
                    self.showModal(isErrorMsg: true, msg: errorString.userInfo["error"] as! String)
                } else {
                    self.showModal(isErrorMsg: false, msg: "User created.\nNow you can login!")
                }
            }
        }
        else{
            showModal(isErrorMsg: true, msg: "All fields are required")
        }
    }
    
    
    func isValidEmail(testStr:String) -> Bool {
        // print("validate calendar: \(testStr)")
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}"
        
        let emailTest = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        return emailTest.evaluate(with: testStr)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let navigationVC = segue.destination as! UINavigationController
        let chatVC = navigationVC.topViewController as! ChatViewController
        
        chatVC.delegate = self
    }
    
}
