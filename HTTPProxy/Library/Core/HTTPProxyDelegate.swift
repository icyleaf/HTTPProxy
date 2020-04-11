import Foundation

protocol HTTPProxyDelegate: AnyObject {

    func shouldFireRequest(urlRequest: URLRequest) -> Bool
    func didFireRequest(request: HTTPRequest)
    func didCompleteRequest(request: HTTPRequest)
}

extension HTTPProxyDelegate {
    func shouldFireRequest(urlRequest: URLRequest) -> Bool {
        return true
    }
    
    func didCompleteRequest(request: HTTPRequest) {
        
    }
}
