//
//  ViewController.swift
//  Braintree Tutorial
//
//  Created by Mikhail Lutskiy on 10.12.2017.
//  Copyright © 2017 BigBadBird. All rights reserved.
//

import UIKit
import Braintree
import BraintreeDropIn

class ViewController: UIViewController {

    @IBOutlet weak var amountField: UITextField!
    
    let tokinizationKey = "sandbox_dm535378_t7y8sss97nrzcz57"
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


    @IBAction func donateAction(_ sender: Any) {
        let request = BTDropInRequest()
        let dropIn = BTDropInController(authorization: tokinizationKey, request: request)
        {
            [unowned self ] (controller, result, error) in
            if let error = error {
                self.show(message: error.localizedDescription)
            } else if ( result?.isCancelled == true) {
                self.show(message: "Transaction cancelled")
            } else if let nonce = result?.paymentMethod?.nonce, let amount = self.amountField.text {
                self.sendRequestPaymentToServer(nonce: nonce, amount: amount)
            }
            controller.dismiss(animated: true, completion: nil)
        }
        
        self.present(dropIn!, animated: true, completion: nil)
    }
    
    func sendRequestPaymentToServer(nonce: String, amount: String) {
        let paymentURL = URL(string: "http://192.168.64.2/donate/pay.php")!
        var request = URLRequest(url: paymentURL)
        request.httpBody = "payment_method_nonce=\(nonce)&amount=\(amount)".data(using: String.Encoding.utf8)
        request.httpMethod = "POST"
        
        URLSession.shared.dataTask(with: request) { [weak self] (data, response, error) -> Void in
            guard let data = data else {
                self?.show(message: error!.localizedDescription)
                return
            }
    
            guard let result = try? JSONSerialization.jsonObject(with: data, options: []) as? [String: Any], let success = result?["success"] as? Bool, success == true else {
                self?.show(message: "Transaction failed. Please try again.")
                return
            }
            self?.show(message: "Successfully charged. Thanks so much :)")
        }.resume()
    }
    
    func show (message: String) {
        DispatchQueue.main.async {
            let alertController = UIAlertController(title: message, message: "", preferredStyle: .alert)
            alertController.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
            self.present(alertController, animated: true, completion: nil)
        }
    }
}

