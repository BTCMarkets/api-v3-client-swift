import Foundation
import SystemConfiguration

let apiKey = "";
let privateKey = "";
let baseUrl = "https://api.btcmarkets.net";

public class CredentialsHTTP : NSObject, URLSessionDelegate
{
    static let sharedInstance : CredentialsHTTP = {
        let instance = CredentialsHTTP()
        
        return instance
    }()
    
    override init() {
        super.init()
    }
    
    func processSessionLoad(_ data: Data) -> Array<Any>
    {
        let jsonResults = try? JSONSerialization.jsonObject(with: data, options: []) as? Array<Any>
        return jsonResults!
    }
    
    func get_order_request()
    {
        let method = "GET"
        let path = "/v3/orders"
        let dataObj = "?status=open"
        
        let timestamp = Date().currentTimeMillis()
        let message = method + path + "\(timestamp)";
        
        let configuration = URLSessionConfiguration.ephemeral
        configuration.timeoutIntervalForRequest = 30
        
        let localOperationQueue = OperationQueue.main
        localOperationQueue.maxConcurrentOperationCount = 20
        
        let session = Foundation.URLSession(configuration: configuration, delegate: self, delegateQueue: localOperationQueue)
        
        let request = self.buildAuthHeaders(method: method, path: path, message: message, timestamp: "\(timestamp)", dataObj: dataObj, jsonObj: nil)

        session.dataTask(with: request, completionHandler:
        {
            (data, response, error) -> Void in
            
            guard error == nil else {
                print(error)
                return
            }

            if let data = data
            {
                let responsePrint = response as? HTTPURLResponse
                session.finishTasksAndInvalidate()
                
                if (responsePrint?.statusCode)! == 200
                {
                    print("--------- Printing Get Order Success ---------")
                    print(self.processSessionLoad(data))
                    print("--------- End Printing Get Order Success ---------")
                } else {
                    let payloadJSONHttpCode = self.errorJson(data)
                    print("--------- Printing Get Order Fail ---------")
                    print(payloadJSONHttpCode["message"])
                    print("--------- End Printing Get Order Fail ---------")
                }
                exit(EXIT_SUCCESS)
            }
        }).resume()
        
        dispatchMain()
    }
    
    func place_order_request()
    {
        let method = "POST"
        let path = "/v3/orders"
        let dataObj = ""
        let jsonObj: [String:String] = ["marketId": "XRP-AUD", "price": "0.1", "amount": "0.1", "side": "Bid", "type": "Limit"]
        
        let timestamp = Date().currentTimeMillis()
        let message = method + path + "\(timestamp)" + self.jsonToString(json: jsonObj as AnyObject);
        
        let configuration = URLSessionConfiguration.ephemeral
        configuration.timeoutIntervalForRequest = 30
        
        let localOperationQueue = OperationQueue.main
        localOperationQueue.maxConcurrentOperationCount = 20
        
        let session = Foundation.URLSession(configuration: configuration, delegate: self, delegateQueue: localOperationQueue)
        
        let request = self.buildAuthHeaders(method: method, path: path, message: message, timestamp: "\(timestamp)", dataObj: dataObj, jsonObj: jsonObj as AnyObject)
        
        let datatask = session.dataTask(with: request, completionHandler:
        {
            (data, response, error) -> Void in
            guard error == nil else {
                return
            }
            
            if let data = data
            {
                let responsePrint = response as? HTTPURLResponse
                session.finishTasksAndInvalidate()
                
                if (responsePrint?.statusCode)! == 200
                {
                    print("--------- Printing Place Order Success ---------")
                    let jsonResults = try? JSONSerialization.jsonObject(with: data, options: []) as? Dictionary<String, Any>
                    print(jsonResults)
                    print("--------- End Printing Place Order Success ---------")
                } else {
                    let payloadJSONHttpCode = self.errorJson(data)
                    print("--------- Printing Place Order Fail ---------")
                    print(payloadJSONHttpCode["message"])
                    print("--------- End Printing Place Order Fail ---------")
                }
                exit(EXIT_SUCCESS)
            }
        })
        datatask.resume()
        dispatchMain()
    }
    
    func cancel_order_request()
    {
        let method = "DELETE"
        let path = "/v3/orders/1228743"
        let dataObj = ""
        
        let timestamp = Date().currentTimeMillis()
        let message = method + path + "\(timestamp)";
        
        let configuration = URLSessionConfiguration.ephemeral
        configuration.timeoutIntervalForRequest = 30
        
        let localOperationQueue = OperationQueue.main
        localOperationQueue.maxConcurrentOperationCount = 20
        
        let session = Foundation.URLSession(configuration: configuration, delegate: self, delegateQueue: localOperationQueue)
        
        let request = self.buildAuthHeaders(method: method, path: path, message: message, timestamp: "\(timestamp)", dataObj: dataObj, jsonObj: nil)
        
        let datatask = session.dataTask(with: request, completionHandler:
        {
            (data, response, error) -> Void in
            guard error == nil else {
                return
            }
            
            if let data = data
            {
                let responsePrint = response as? HTTPURLResponse
                session.finishTasksAndInvalidate()
                
                if (responsePrint?.statusCode)! == 200
                {
                    print("--------- Printing Cancel Order Success ---------")
                    let jsonResults = try? JSONSerialization.jsonObject(with: data, options: []) as? Dictionary<String, Any>
                    print(jsonResults)
                    print("--------- End Printing Cancel Order Success ---------")
                } else {
                    let payloadJSONHttpCode = self.errorJson(data)
                    print("--------- Printing Cancel Order Fail ---------")
                    print(payloadJSONHttpCode["message"])
                    print("--------- End Printing Cancel Order Fail ---------")
                }
                exit(EXIT_SUCCESS)
            }
        })
        datatask.resume()
        dispatchMain()
    }
    
    func buildAuthHeaders(method: String, path: String, message: String, timestamp: String, dataObj: String, jsonObj: AnyObject?) -> URLRequest {
        let preppedUrlString = String(format: "%@", baseUrl + path + dataObj)
        
        let url: URL = URL(string: preppedUrlString)!
        
        var request = URLRequest(url: url)
        
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        request.setValue("UTF-8", forHTTPHeaderField: "Accept-Charset")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue(apiKey, forHTTPHeaderField: "BM-AUTH-APIKEY")
        request.setValue("\(timestamp)", forHTTPHeaderField: "BM-AUTH-TIMESTAMP")
        request.setValue(signMessage(message: message), forHTTPHeaderField: "BM-AUTH-SIGNATURE")
        request.httpMethod = method
        request.cachePolicy = NSURLRequest.CachePolicy.reloadIgnoringCacheData
        
        if let actualJsonObj = jsonObj {
            if (JSONSerialization.isValidJSONObject(jsonObj)) {
                do {
                    request.httpBody = try JSONSerialization.data(withJSONObject: jsonObj, options: .prettyPrinted)
                } catch {
                    return request
                }
            }
            
        }
        return request
    }
    
    func signMessage(message: String) -> String {
        guard let payload = Data(base64Encoded: privateKey) else {
            return ""}
        let decodedPrivateAPIKey = convert64EncodedToHex(payload)
        let decodedPrivateAPIKeyByteArray = decodedPrivateAPIKey.hexa
        let stringToSignData: [UInt8] = Array(message.utf8)
        var signature = ""
        do {
            let signatureArray = try HMAC(key: decodedPrivateAPIKeyByteArray, variant: .sha512).authenticate(stringToSignData)
            if let conversion = signatureArray.toBase64(){
                signature = conversion
            }
        } catch {
            print(error)
        }
        return signature
    }
    
    func convert64EncodedToHex(_ data:Data) -> String {
        return data.map{ String(format: "%02x", $0) }.joined()
    }
    
    func errorJson(_ data: Data)->Dictionary<String, Any> {
        let jsonResults = try? JSONSerialization.jsonObject(with: data, options: []) as! Dictionary<String, Any>
        return jsonResults!
    }
    
    func jsonToString(json: AnyObject) -> String {
        do {
            let data1 =  try JSONSerialization.data(withJSONObject: json, options: JSONSerialization.WritingOptions.prettyPrinted) // first of all convert json to the data
            let convertedString = String(data: data1, encoding: String.Encoding.utf8) // the data will be converted to the string
            return convertedString!
        } catch let myJSONError {
            print(myJSONError)
            return ""
        }
    }
}

extension Date {
    func currentTimeMillis() -> Int64 {
        return Int64(self.timeIntervalSince1970 * 1000)
    }
}

extension String {
    
    func fromBase64() -> String? {
        guard let data = Data(base64Encoded: self) else {
            return nil
        }
        
        return String(data: data, encoding: .utf8)
    }
    
    func toBase64() -> String {
        return Data(self.utf8).base64EncodedString()
    }
}

extension StringProtocol {
    var hexa: [UInt8] {
        var startIndex = self.startIndex
        return stride(from: 0, to: count, by: 2).compactMap { _ in
            let endIndex = index(startIndex, offsetBy: 2, limitedBy: self.endIndex) ?? self.endIndex
            defer { startIndex = endIndex }
            return UInt8(self[startIndex..<endIndex], radix: 16)
        }
    }
}

