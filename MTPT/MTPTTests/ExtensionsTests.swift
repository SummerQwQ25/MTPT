import XCTest
@testable import MTPT

class ExtensionsTests: XCTestCase {
    
    func testStringExtension() {
        // 测试非空字符串
        let nonEmptyString: String? = "Hello"
        XCTAssertFalse(nonEmptyString.isNilOrEmpty)
        
        // 测试空字符串
        let emptyString: String? = ""
        XCTAssertTrue(emptyString.isNilOrEmpty)
        
        // 测试nil字符串
        let nilString: String? = nil
        XCTAssertTrue(nilString.isNilOrEmpty)
    }
    
    func testArrayExtension() {
        // 测试非空数组
        let nonEmptyArray: [Any]? = [1, 2, 3]
        XCTAssertFalse(nonEmptyArray.isNilOrEmpty)
        
        // 测试空数组
        let emptyArray: [Any]? = []
        XCTAssertTrue(emptyArray.isNilOrEmpty)
        
        // 测试nil数组
        let nilArray: [Any]? = nil
        XCTAssertTrue(nilArray.isNilOrEmpty)
    }
} 