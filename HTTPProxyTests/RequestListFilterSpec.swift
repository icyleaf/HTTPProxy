@testable import HTTPProxy
import Quick
import Nimble

extension HTTPRequest {
    convenience init?(url: String, method: String? = "GET") {
        guard let url = URL(string: url) else {
            return nil
        }
        var request = URLRequest(url: url)
        request.httpMethod = method
        self.init(request: request)
    }
}

class RequestListFilterSpec: QuickSpec {
    override func spec() {
        
        var sut: RequestListFilter!
        
        beforeEach {
            sut = RequestListFilter()
        }
        
        describe("filterRequests") {
            
            context("scheme filter") {
                
                context("http filter") {
                    let requestFilter = RequestFilter(scheme: "http")
                    let filter = HTTPProxyFilter(name: "http", requestFilter: requestFilter)
                    filter.enabled = true
                    
                    it("doesn't filter http requests") {
                        let httpRequest = HTTPRequest(url: "http://postman-echo.com/get?foo1=bar1&foo2=bar2")!
                        
                        let result = sut.filterRequests([httpRequest], with: [filter])
                        
                        expect(result).to(equal([httpRequest]))
                    }
                    
                    it("filters out https requests") {
                        let httpRequest = HTTPRequest(url: "https://postman-echo.com/get?foo1=bar1&foo2=bar2")!
                        
                        let result = sut.filterRequests([httpRequest], with: [filter])
                        
                        expect(result).to(beEmpty())
                    }
                }
                
                context("https filter") {
                    let requestFilter = RequestFilter(scheme: "https")
                    let filter = HTTPProxyFilter(name: "https", requestFilter: requestFilter)
                    filter.enabled = true
                    
                    it("doesn't filter https requests") {
                        let httpRequest = HTTPRequest(url: "https://postman-echo.com/get?foo1=bar1&foo2=bar2")!
                        
                        let result = sut.filterRequests([httpRequest], with: [filter])
                        
                        expect(result).to(equal([httpRequest]))
                    }
                    
                    it("filters out http requests") {
                        let httpRequest = HTTPRequest(url: "http://postman-echo.com/get?foo1=bar1&foo2=bar2")!
                        
                        let result = sut.filterRequests([httpRequest], with: [filter])
                        
                        expect(result).to(beEmpty())
                    }
                }
            }
            
            context("httpMethod filter") {
                
                context("http filter") {
                    let requestFilter = RequestFilter(httpMethod: "POST")
                    let filter = HTTPProxyFilter(name: "POST", requestFilter: requestFilter)
                    filter.enabled = true
                    
                    it("doesn't filter http requests") {
                        let postRequest = HTTPRequest(url: "https://jsonplaceholder.typicode.com/posts/0", method: "POST")!
                        let putRequest = HTTPRequest(url: "https://jsonplaceholder.typicode.com/posts/0", method: "PUT")!
                        let deleteRequest = HTTPRequest(url: "https://jsonplaceholder.typicode.com/posts/0", method: "DELETE")!
                        
                        let requests = [deleteRequest, putRequest, postRequest]
                        let result = sut.filterRequests(requests, with: [filter])
                        
                        expect(result).to(equal([postRequest]))
                    }
                }
            }
            
            context("query filter") {
                
                context("query filter with key and value") {
                    let requestFilter = RequestFilter(queryItems: [KeyValuePair("foo", "bar")])
                    let filter = HTTPProxyFilter(name: "query", requestFilter: requestFilter)
                    filter.enabled = true
                    
                    itBehavesLike(RequestNotFilteredOut.self) { () -> (RequestListFilter, HTTPRequest, HTTPProxyFilter) in
                        (sut, HTTPRequest(url: "https://postman-echo.com/get?foo2=bar2&foo=bar")!, filter)
                    }
                    
                    itBehavesLike(RequestFilteredOut.self) { () -> (RequestListFilter, HTTPRequest, HTTPProxyFilter) in
                        (sut, HTTPRequest(url: "https://postman-echo.com/get")!, filter)
                    }
                    
                    itBehavesLike(RequestFilteredOut.self) { () -> (RequestListFilter, HTTPRequest, HTTPProxyFilter) in
                        (sut, HTTPRequest(url: "https://postman-echo.com/get?foo2=bar")!, filter)
                    }
                    
                    itBehavesLike(RequestFilteredOut.self) { () -> (RequestListFilter, HTTPRequest, HTTPProxyFilter) in
                        (sut, HTTPRequest(url: "https://postman-echo.com/get?foo=baz")!, filter)
                    }
                    
                    itBehavesLike(RequestFilteredOut.self) { () -> (RequestListFilter, HTTPRequest, HTTPProxyFilter) in
                        (sut, HTTPRequest(url: "https://postman-echo.com/get?bar=foo")!, filter)
                    }
                    
                    itBehavesLike(RequestFilteredOut.self) { () -> (RequestListFilter, HTTPRequest, HTTPProxyFilter) in
                        (sut, HTTPRequest(url: "https://postman-echo.com/get?foo=&a=bar")!, filter)
                    }
                    
                    itBehavesLike(RequestFilteredOut.self) { () -> (RequestListFilter, HTTPRequest, HTTPProxyFilter) in
                        (sut, HTTPRequest(url: "https://postman-echo.com/get?foobar=bar")!, filter)
                    }
                }
                
                context("query filter with key only") {
                    let requestFilter = RequestFilter(queryItems: [KeyValuePair("foo", nil)])
                    let filter = HTTPProxyFilter(name: "query", requestFilter: requestFilter)
                    filter.enabled = true
                    
                    itBehavesLike(RequestNotFilteredOut.self) { () -> (RequestListFilter, HTTPRequest, HTTPProxyFilter) in
                        (sut, HTTPRequest(url: "https://postman-echo.com/get?foo2=bar2&foo=bar")!, filter)
                    }
                    
                    itBehavesLike(RequestNotFilteredOut.self) { () -> (RequestListFilter, HTTPRequest, HTTPProxyFilter) in
                        (sut, HTTPRequest(url: "https://postman-echo.com/get?ab=cd&foo=&z=y")!, filter)
                    }
                    
                    itBehavesLike(RequestFilteredOut.self) { () -> (RequestListFilter, HTTPRequest, HTTPProxyFilter) in
                        (sut, HTTPRequest(url: "https://postman-echo.com/get")!, filter)
                    }
                    
                    itBehavesLike(RequestFilteredOut.self) { () -> (RequestListFilter, HTTPRequest, HTTPProxyFilter) in
                        (sut, HTTPRequest(url: "https://postman-echo.com/get?foo2=bar")!, filter)
                    }
                    
                    itBehavesLike(RequestFilteredOut.self) { () -> (RequestListFilter, HTTPRequest, HTTPProxyFilter) in
                        (sut, HTTPRequest(url: "https://postman-echo.com/get?abc=foo")!, filter)
                    }
                    
                    itBehavesLike(RequestFilteredOut.self) { () -> (RequestListFilter, HTTPRequest, HTTPProxyFilter) in
                        (sut, HTTPRequest(url: "https://postman-echo.com/get?foobar=bar")!, filter)
                    }
                }
            }
        }
    }
}

class RequestNotFilteredOut: Behavior<(RequestListFilter, HTTPRequest, HTTPProxyFilter)> {
    override class func spec(_ context: @escaping () -> (RequestListFilter, HTTPRequest, HTTPProxyFilter)) {
        
        var sut: RequestListFilter!
        var httpRequest: HTTPRequest!
        var filter: HTTPProxyFilter!
        
        beforeEach {
            sut = context().0
            httpRequest = context().1
            filter = context().2
        }
        
        it("does not filter the request") {
            let result = sut.filterRequests([httpRequest], with: [filter])
            
            expect(result).to(equal([httpRequest]))
        }
    }
}

class RequestFilteredOut: Behavior<(RequestListFilter, HTTPRequest, HTTPProxyFilter)> {
    override class func spec(_ context: @escaping () -> (RequestListFilter, HTTPRequest, HTTPProxyFilter)) {
        
        var sut: RequestListFilter!
        var httpRequest: HTTPRequest!
        var filter: HTTPProxyFilter!
        
        beforeEach {
            sut = context().0
            httpRequest = context().1
            filter = context().2
        }
        
        it("filters out the request") {
            let result = sut.filterRequests([httpRequest], with: [filter])
            
            expect(result).to(beEmpty())
        }
    }
}
