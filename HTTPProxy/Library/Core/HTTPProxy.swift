import Foundation

public class HTTPProxy {

    public static let shared = HTTPProxy()

    private let queue = DispatchQueue(label: "HTTPProxy")
    var requests = [HTTPRequest]()
    var enabled = false
    weak var delegate: HTTPProxyDelegate?

    public func enable() {
        guard !enabled else { return }

        enabled = true
        HTTPProxyRequestInterceptor.shared.delegate = self
        HTTPProxyRequestInterceptor.shared.activate()
    }

    public func disable() {
        guard enabled else { return }

        enabled = false
        HTTPProxyRequestInterceptor.shared.delegate = nil
        HTTPProxyRequestInterceptor.shared.deactivate()
    }
    
    public func clearRequests() {
        requests.removeAll()
    }
    
    public func presentViewController() {
        HTTPProxyPresenter.shared.presentViewController()
    }

    private func requestFor(urlRequest: URLRequest) -> HTTPRequest? {
        return requests.first(where: { httpRequest -> Bool in
            httpRequest.request == urlRequest && httpRequest.response == nil
        })
    }
}

extension HTTPProxy: HTTPProxyRequestInterceptorDelegate {

    func shouldFireRequest(urlRequest: URLRequest) -> Bool {
        return delegate?.shouldFireRequest(urlRequest: urlRequest) ?? true
    }

    func willFireRequest(urlRequest: URLRequest) {
        queue.sync {
            let request = HTTPRequest(request: urlRequest)
            requests.insert(request, at: 0)
            delegate?.didFireRequest(request: request)
        }
    }

    public func didReceiveResponse(urlRequest: URLRequest, response: HTTPURLResponse, data: Data?) {
        queue.sync {
            if let httpRequest = requestFor(urlRequest: urlRequest) {
                httpRequest.responseDate = Date()
                httpRequest.response = HTTPResponse.success(response: response, data: data)
                delegate?.didCompleteRequest(request: httpRequest)
            }
        }
    }

    public func didComplete(request urlRequest: URLRequest, response: HTTPURLResponse?, error: Error?) {
        queue.sync {
            if let httpRequest = requestFor(urlRequest: urlRequest) {
                httpRequest.response = HTTPResponse.failure(response: response, error: error)
                httpRequest.responseDate = Date()
            }
        }
    }
}
