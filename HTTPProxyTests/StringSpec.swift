@testable import HTTPProxy
import Quick
import Nimble

class StringSpec: QuickSpec {
    override func spec() {
        describe("keyValuePairs") {
            context("Parse success") {
                itBehavesLike(ParseSuccess.self) { () -> (String, [KeyValuePair]) in
                    ("a=b", [KeyValuePair("a", "b")])
                }
                
                itBehavesLike(ParseSuccess.self) { () -> (String, [KeyValuePair]) in
                    ("a=b&c=d", [KeyValuePair("a", "b"), KeyValuePair("c", "d")])
                }
                
                itBehavesLike(ParseSuccess.self) { () -> (String, [KeyValuePair]) in
                    ("key_only", [KeyValuePair("key_only")])
                }
                
                itBehavesLike(ParseSuccess.self) { () -> (String, [KeyValuePair]) in
                    ("key=val&key_only", [KeyValuePair("key", "val"), KeyValuePair("key_only")])
                }
            }
            context("Parse failure") {
                itBehavesLike(ParseFailure.self) { () -> String in
                    ""
                }
                itBehavesLike(ParseFailure.self) { () -> String in
                    "="
                }
                itBehavesLike(ParseFailure.self) { () -> String in
                    "=val"
                }
                itBehavesLike(ParseFailure.self) { () -> String in
                    "a=b="
                }
                itBehavesLike(ParseFailure.self) { () -> String in
                    "a==b"
                }
                itBehavesLike(ParseFailure.self) { () -> String in
                    "&a=b"
                }
            }
        }
    }
}

private class ParseSuccess: Behavior<(String, [KeyValuePair])> {
    override class func spec(_ context: @escaping () -> (String, [KeyValuePair])) {
        
        var sut: String!
        var expectedResult: [KeyValuePair]!
        
        beforeEach {
            sut = context().0
            expectedResult = context().1
        }
        
        it("keyValuePairs returns the expected result") {
            let pairs = sut.keyValuePairs()
            
            expect(pairs).to(equal(expectedResult))
        }
    }
}

private class ParseFailure: Behavior<String> {
    override class func spec(_ context: @escaping () -> String) {
        
        var sut: String!
        
        beforeEach {
            sut = context()
        }
        
        it("keyValuePairs returns nil") {
            let pairs = sut.keyValuePairs()
            
            expect(pairs).to(beNil())
        }
    }
}
