import XCTest
@testable import MTPT

class MockPreviewViewController: PreviewViewController {
    var imageSavedCalled = false
    var savedWithError = false
    var lastError: Error?
    
    override func imageSaved(_ image: UIImage, didFinishSavingWithError error: Error?, contextInfo: UnsafeRawPointer) {
        imageSavedCalled = true
        lastError = error
        savedWithError = error != nil
        // 不调用super避免真实的UI弹窗
    }
}

class ImageSavingTests: XCTestCase {
    
    var mockPreviewVC: MockPreviewViewController!
    // 创建一个可复用的安全指针
    let dummyPointer = UnsafeMutableRawPointer.allocate(byteCount: 1, alignment: 1)
    
    override func setUp() {
        super.setUp()
        mockPreviewVC = MockPreviewViewController(questionText: "测试问题", answerText: "测试答案", isColorEnabled: false)
        _ = mockPreviewVC.view // 加载视图
    }
    
    override func tearDown() {
        mockPreviewVC = nil
        // 释放我们分配的指针
        dummyPointer.deallocate()
        super.tearDown()
    }
    
    func testImageSavedCallback() {
        // 使用安全的非nil指针
        mockPreviewVC.imageSaved(UIImage(), didFinishSavingWithError: nil, contextInfo: dummyPointer)
        
        XCTAssertTrue(mockPreviewVC.imageSavedCalled)
        XCTAssertFalse(mockPreviewVC.savedWithError)
        XCTAssertNil(mockPreviewVC.lastError)
    }
    
    func testImageSavedWithError() {
        let error = NSError(domain: "TestErrorDomain", code: 100, userInfo: [NSLocalizedDescriptionKey: "测试错误"])
        
        // 使用安全的非nil指针
        mockPreviewVC.imageSaved(UIImage(), didFinishSavingWithError: error, contextInfo: dummyPointer)
        
        XCTAssertTrue(mockPreviewVC.imageSavedCalled)
        XCTAssertTrue(mockPreviewVC.savedWithError)
        XCTAssertNotNil(mockPreviewVC.lastError)
        
        if let savedError = mockPreviewVC.lastError as NSError? {
            XCTAssertEqual(savedError.domain, "TestErrorDomain")
            XCTAssertEqual(savedError.code, 100)
        } else {
            XCTFail("错误类型不匹配")
        }
    }
} 
