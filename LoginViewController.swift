//
//  LoginViewController.swift
//  RowTime
//
//  Created by Paul Ventisei on 06/10/2018.
//  Copyright © 2018 Paul Ventisei. All rights reserved.
//

import UIKit
import Firebase

class LoginViewController: UIViewController {
    
    var loginHandle: AuthStateDidChangeListenerHandle?
    @IBOutlet weak var userName: UITextField!
    @IBOutlet weak var password: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        
        loginHandle = Auth.auth().addStateDidChangeListener { auth, user in
            if user != nil {
                self.performSegue(withIdentifier: "loginToNavigation", sender: nil)
                self.userName.text = nil
                self.password.text = nil
                print("user data \(user!.email)")
            }
        }
        
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        
        Auth.auth().removeStateDidChangeListener(loginHandle!)
        
    }
    
    @IBAction func login(_ sender: Any) {
        //check that both the name and the password have been set
        if userName.isEqual(""), password.isEqual(""){
            //either password or username were not set so return without doing anything
            print("either password or username was not set")
        }else {
            // call API to sign-in with the password.  If successful then the login state will change an the statechange listener will seque to the neavigator.  If there is an error then a pop up alert will tell the user what the issue was
            Auth.auth().signIn(withEmail: userName.text!, password: password.text!) { [weak self] user, error in
                guard let strongSelf = self else { return }
                print("login attempt \(String(describing: user)) \(String(describing: error))")
                //error handling
                if let error = error, user == nil {
                    let alert = UIAlertController(title: "Sign In Failed",
                                                  message: error.localizedDescription,
                                                  preferredStyle: .alert)
                    
                    alert.addAction(UIAlertAction(title: "OK", style: .default))
                    
                    strongSelf.present(alert, animated: true, completion: nil)
                }
            }
        }
    }
    
    @IBAction func register(_ sender: UIButton) {
        if userName.isEqual(""), password.isEqual(""){
            //either password or username were not set so return without doing anything
            print("either password or username was not set")
        }else {
            Auth.auth().createUser(withEmail: userName.text!, password: password.text!) { authResult, error in
            // action to be done as well as registering the user
        }
        
      }
    }
    
    @IBAction func unwindToLogin(segue: UIStoryboardSegue) {
        
    }
    
    
}
