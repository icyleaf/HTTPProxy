import Foundation

class HTTPProxyRequestInterceptor {

    static let shared = HTTPProxyRequestInterceptor()
    let configuration: URLSessionConfiguration
    weak var delegate: HTTPProxyRequestInterceptorDelegate?
    internal static let protocolKey = "URLProtocol"
    internal static let protocolValue = "HTTPProxyURLProtocol"

    init() {
        configuration = URLSessionConfiguration.default
        configuration.httpAdditionalHeaders = [HTTPProxyRequestInterceptor.protocolKey: HTTPProxyRequestInterceptor.protocolValue]
    }

    func activate() {
        URLProtocol.registerClass(HTTPProxyURLProtocol.self)
        swizzleProtocolClasses()
    }

    func deactivate() {
        URLProtocol.unregisterClass(HTTPProxyURLProtocol.self)
        swizzleProtocolClasses()
    }

    func shouldFireRequest(_ urlRequest: URLRequest) -> Bool {
        return delegate?.shouldFireRequest(urlRequest: urlRequest) ?? false
    }

    func willFireRequest(_ urlRequest: URLRequest) {
        delegate?.willFireRequest(urlRequest: urlRequest)
    }

    func didReceiveResponse(urlRequest: URLRequest, response: HTTPURLResponse, data: Data) {
        delegate?.didReceiveResponse(urlRequest: urlRequest, response: response, data: data)
    }

    func didComplete(request: URLRequest, response: HTTPURLResponse?, error: Error?) {
        delegate?.didComplete(request: request, response: response, error: error)
    }

    private func swizzleProtocolClasses() {
        let instance = URLSessionConfiguration.default
        let uRLSessionConfigurationClass: AnyClass = object_getClass(instance)!

        let method1: Method = class_getInstanceMethod(uRLSessionConfigurationClass, #selector(getter: uRLSessionConfigurationClass.protocolClasses))!
        let method2: Method = class_getInstanceMethod(URLSessionConfiguration.self, #selector(URLSessionConfiguration.fakeProcotolClasses))!

        method_exchangeImplementations(method1, method2)
    }
}

extension URLSessionConfiguration {

    /*
        Include HTTPProxyURLProtocol in the list of protocolClasses returned by any instance of URLSessionConfiguration
        excluding the configuration used to send the requests from the HTTPProxyURLProtocol protocol itself
    */
    @objc
    func fakeProcotolClasses() -> [AnyClass]? {
        guard let fakeProcotolClasses = self.fakeProcotolClasses() else {
            return []
        }

        if self.httpAdditionalHeaders?[HTTPProxyRequestInterceptor.protocolKey] as? String == HTTPProxyRequestInterceptor.protocolValue {
            return fakeProcotolClasses
        }

        var originalProtocolClasses = fakeProcotolClasses.filter {
            return $0 != HTTPProxyURLProtocol.self
        }
        originalProtocolClasses.insert(HTTPProxyURLProtocol.self, at: 0)
        return originalProtocolClasses
    }
}
