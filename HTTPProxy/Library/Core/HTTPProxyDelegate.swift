import Foundation

public protocol HTTPProxyDelegate: AnyObject {

    func shouldFireURLRequest(_ urlRequest: URLRequest) -> Bool
    func willFireRequest(_ httpRequest: HTTPRequest)
    func didCompleteRequest(_ httpRequest: HTTPRequest)
}
