import Foundation
import UIKit

private struct RequestFields: SearchableListItem {
    
    let key: String
    let value: String
    
    var method: String? {
        return nil
    }
    var statusCode: Int? {
        return nil
    }
    var requestStatus: RequestStatus? {
        return nil
    }
}

class RequestDetailsPresenter {
    private let request: HTTPRequest
    private let viewController: RequestDetailsViewController
    private let presentingViewController: UINavigationController
    private var viewControllers: [UIViewController] = []
    
    init(request: HTTPRequest, presentingViewController: UINavigationController) {
        self.request = request
        self.presentingViewController = presentingViewController
        self.viewController = RequestDetailsViewController(nibName: "RequestDetailsViewController", bundle: HTTPProxyPresenter.bundle)
        self.viewController.delegate = self
        let title = request.request.url?.host ?? "Request Details"
        self.viewController.title = title
        
        let vc1 = Summary().requestController(httpRequest: request)
        let vc2 = Request(presenter: self).requestController(httpRequest: request)
        let vc3 = Response(presenter: self).requestController(httpRequest: request)
        self.viewControllers.append(vc1)
        self.viewControllers.append(vc2)
        self.viewControllers.append(vc3)
    }
    
    func present() {
        self.presentingViewController.pushViewController(viewController, animated: true)
    }
    
    func openTextViewer(text: String, filename: String) {
        let console = TextViewerViewController(text: text, filename: filename)
        console.modalPresentationStyle = .fullScreen
        self.presentingViewController.pushViewController(console, animated: true)
    }
}

extension RequestDetailsPresenter: RequestDetailsViewControllerDelegate {
    func viewController(index: Int) -> UIViewController {
        return viewControllers[index]
    }
}

private struct Summary {
    
    func requestController(httpRequest: HTTPRequest) -> SearchableListViewController {
        let viewController = SearchableListViewController(nibName: "SearchableListViewController", bundle: HTTPProxyPresenter.bundle)
        viewController.sections = sectionData(httpRequest: httpRequest) ?? []
        return viewController
    }
    
    func sectionData(httpRequest: HTTPRequest) -> [SearchableListSection]? {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "HH:mm:ss.SSS"
        let requestDate = dateFormatter.string(from: httpRequest.requestDate)
        
        var requestData: [(String, String)] = []
        requestData.append(("Request date", requestDate))
        
        if let date = httpRequest.responseDate {
            let responseDate = dateFormatter.string(from: date)
            requestData.append(("Response date", responseDate))
            let interval = String(format: "%.2f ms", date.timeIntervalSince(httpRequest.requestDate))
            requestData.append(("Interval", interval))
        }
        
        if let method = httpRequest.request.httpMethod {
            requestData.append(("Method", method))
        }
        
        requestData.append(("Timeout", "\(httpRequest.request.timeoutInterval)"))
        
        if let response = httpRequest.response {
            var statusCode: Int?
            if case .success(let response, _) = response {
                statusCode = response.statusCode
            } else if case .failure(let response, let error as NSError) = response {
                statusCode = response?.statusCode
                requestData.append(("Error", "\(error.domain)(\(error.code)): \(error.localizedDescription)"))
            }
            if let status = statusCode {
                requestData.append(("Status", "\(status)"))
            }
        }
        
        if let url = httpRequest.request.url {
            requestData.append(("URL", url.absoluteString))
        }
        
        var requestFields: [RequestFields] = []
        for (key, value) in requestData {
            let item = RequestFields(key: key, value: value)
            requestFields.append(item)
        }
        
        let section = SearchableListSection(title: nil, items: requestFields)
        return [section]
    }
}

private struct Request {
    
    weak var presenter: RequestDetailsPresenter!
    
    init(presenter: RequestDetailsPresenter) {
        self.presenter = presenter
    }
    
    func requestController(httpRequest: HTTPRequest) -> SearchableListViewController {
        let viewController = SearchableListViewController(nibName: "SearchableListViewController", bundle: HTTPProxyPresenter.bundle)
        
        var requestFields: [RequestFields] = []
        if let allHTTPHeaderFields = httpRequest.request.allHTTPHeaderFields {
            for (key, value) in allHTTPHeaderFields {
                let item = RequestFields(key: key, value: value)
                requestFields.append(item)
            }
        }
        
        let sortedHeaders = requestFields.sorted { field1, field2 -> Bool in
            return field1.key < field2.key
        }
        
        if let bodyString = httpRequest.requestBodyString {
            viewController.buttonTitle = "Show Request Body"
            viewController.buttonCallback = {
                self.presenter.openTextViewer(text: bodyString, filename: "Request Body")
            }
        }
        
        var parameters: [RequestFields] = []
        if let url = httpRequest.request.url,
            let urlComponents = NSURLComponents(url: url, resolvingAgainstBaseURL: true),
            let queryItems = urlComponents.queryItems, !queryItems.isEmpty {
            for (param) in queryItems {
                let item = RequestFields(key: param.name, value: param.value ?? "")
                parameters.append(item)
            }
        }
        
        let headersSection = SearchableListSection(title: "Request Headers", items: sortedHeaders)
        let paramsSection = SearchableListSection(title: "Query parameters", items: parameters)
        viewController.sections = [headersSection, paramsSection]
        return viewController
    }
}

private struct Response {
    
    weak var presenter: RequestDetailsPresenter!
    
    init(presenter: RequestDetailsPresenter) {
        self.presenter = presenter
    }
    
    func requestController(httpRequest: HTTPRequest) -> SearchableListViewController {
        let viewController = SearchableListViewController(nibName: "SearchableListViewController", bundle: HTTPProxyPresenter.bundle)
        let headers = sortedHeaders(httpRequest: httpRequest) ?? []
        let paramsSection = SearchableListSection(title: "Response Headers", items: headers)
        viewController.sections = [paramsSection]
        
        if canShowResponse(httpRequest: httpRequest) {
            viewController.buttonTitle = "Show Response Body"
            viewController.buttonCallback = {
                self.showResponse(httpRequest: httpRequest)
            }
        }
        return viewController
    }
    
    func sortedHeaders(httpRequest: HTTPRequest) -> [RequestFields]? {
        guard let urlResponse = httpRequest.response?.urlResponse else {
            return nil
        }
        
        var requestFields: [RequestFields] = []
        for (key, value) in urlResponse.allHeaderFields {
            let item = RequestFields(key: key.description, value: String(describing: value))
            requestFields.append(item)
        }
        
        let sortedHeaders = requestFields.sorted { field1, field2 -> Bool in
            return field1.key < field2.key
        }
        return sortedHeaders
    }
    
    private func canShowResponse(httpRequest: HTTPRequest) -> Bool {
        return responseData(httpRequest: httpRequest) != nil
    }
    
    private func responseData(httpRequest: HTTPRequest) -> Data? {
        httpRequest.response?.responseData
    }
    
    private func suggestedFilename(httpRequest: HTTPRequest) -> String? {
        guard case .success(let response, _)? = httpRequest.response else {
            return nil
        }
        return response.suggestedFilename
    }
    
    private func showResponse(httpRequest: HTTPRequest) {
        guard let data = responseData(httpRequest: httpRequest) as Data? else {
            return
        }
        
        let filename = suggestedFilename(httpRequest: httpRequest) ?? ""
        if let jsonString = data.toJsonString() {
            viewFile(content: jsonString, filename: filename)
            return
        }
        
        if let content = data.toString(encoding: .utf8) {
            viewFile(content: content, filename: filename)
            return
        }
        
        if let response = httpRequest.response?.responseString {
            viewFile(content: response, filename: filename)
        }
    }
    
    private func viewFile(content: String, filename: String) {
        presenter.openTextViewer(text: content, filename: filename)
    }
}
