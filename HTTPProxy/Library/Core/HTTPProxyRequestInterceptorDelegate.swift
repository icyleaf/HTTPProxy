import Foundation

protocol HTTPProxyRequestInterceptorDelegate: AnyObject {

    func shouldFireRequest(urlRequest: URLRequest) -> Bool
    func willFireRequest(urlRequest: URLRequest)
    func didReceiveResponse(urlRequest: URLRequest, response: HTTPURLResponse, data: Data?)
    func didComplete(request: URLRequest, response: HTTPURLResponse?, error: Error?)
}
