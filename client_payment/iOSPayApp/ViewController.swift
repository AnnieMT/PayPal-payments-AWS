//
//  ViewController.swift
//  iOSPayApp
//
//  Created by Bear Cahill on 5/29/19.
//  Copyright © 2019 Bear Cahill. All rights reserved.
//

import UIKit
import Braintree
import BraintreeDropIn

let APIendpoint =  "https://b5qwrica86.execute-api.us-west-2.amazonaws.com/default/PaymentLambda"
let APIkey = "TX9vc27Nn39yCoegvUxOw6QgegVdxAyO7PqL7YVo"

class ServerResponse : Codable {
    var statusCode = 0
    var token = ""
}

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        fetchClientToken { (value) in
            print(value?.token ?? "no value")
            if let token = value?.token {
                self.showUI(token: token)
            }
        }
    }
    
    func showUI(token: String) {
        let req = BTDropInRequest()
        let dropin = BTDropInController(authorization: token, request: req) { (controller, result, error) in
            guard error == nil else { return }
            guard let res = result, res.isCancelled == false else { return }
            guard let nonce = res.paymentMethod?.nonce else { return }
            print (nonce)
            controller.dismiss(animated: true, completion: nil)
            self.sendTransaction(amount: 21.34, nonce: nonce, completion: { (str) in
                print (str)
            })
        }
        if let vc = dropin {
            self.present(vc, animated: false, completion: nil)
        }
        
    }

    func sendTransaction(amount: Double, nonce: String, completion: @escaping (String?)->Void) {
        guard let url = URL(string: APIendpoint) else { completion(nil); return }
        var req = URLRequest(url: url)
        req.addValue("text/plain", forHTTPHeaderField: "Accept")
        req.addValue(APIkey, forHTTPHeaderField: "x-api-key")
        req.httpMethod = "POST"
        let param = """
        {"amount":\(amount), "action":"payment", "nonce":"\(nonce)", "custId":""}
        """
        req.httpBody = param.data(using: .utf8)
        
        URLSession.shared.dataTask(with: req) { (data, response, error) in
            guard let d = data, error == nil else { completion(nil); return }
            guard let str = String(data: d, encoding: .utf8) else { completion(nil); return }
//            guard let sr = try? JSONDecoder().decode(ServerResponse.self, from: d) else { completion(nil); return }
            completion(str)
            }.resume()
    }

    
    func fetchClientToken(completion: @escaping (ServerResponse?)->Void) {
        guard let url = URL(string: APIendpoint) else { completion(nil); return }
        var req = URLRequest(url: url)
        req.addValue("text/plain", forHTTPHeaderField: "Accept")
        req.addValue(APIkey, forHTTPHeaderField: "x-api-key")
        req.httpMethod = "POST"
        let param = """
            {"custId":"508642293", "action":"token"}
        """
        req.httpBody = param.data(using: .utf8)
        
        URLSession.shared.dataTask(with: req) { (data, response, error) in
            guard let d = data, error == nil else { completion(nil); return }
//            guard let str = String(data: d, encoding: .utf8) else { completion(nil); return }
            guard let sr = try? JSONDecoder().decode(ServerResponse.self, from: d) else { completion(nil); return }
            completion(sr)
        }.resume()
    }

}

