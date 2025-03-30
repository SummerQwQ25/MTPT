import XCTest
import MarkdownView
@testable import MTPT

class PreviewViewControllerTests: XCTestCase {
    
    var previewVC: PreviewViewController!
    let testQuestion = "这是测试问题"
    let testAnswer = "这是测试答案，**加粗文本**，*斜体文本*"
    
    override func setUp() {
        super.setUp()
        previewVC = PreviewViewController(questionText: testQuestion, answerText: testAnswer, isColorEnabled: true)
        _ = previewVC.view // 加载视图
    }
    
    override func tearDown() {
        previewVC = nil
        super.tearDown()
    }
    
    func testInitialSetup() {
        // 测试初始化状态
        XCTAssertNotNil(previewVC.view)
        XCTAssertEqual(previewVC.title, "预览")
        
        // 测试传入的参数是否正确保存
        XCTAssertEqual(previewVC.value(forKey: "questionText") as? String, testQuestion)
        XCTAssertEqual(previewVC.value(forKey: "answerText") as? String, testAnswer)
        XCTAssertEqual(previewVC.value(forKey: "isColorEnabled") as? Bool, true)
        
        // 测试 UI 元素是否已创建
        let scrollView = previewVC.value(forKey: "scrollView") as? UIScrollView
        let contentView = previewVC.value(forKey: "contentView") as? UIView
        let questionMarkdownView = previewVC.value(forKey: "questionMarkdownView") as? MarkdownView
        let answerMarkdownView = previewVC.value(forKey: "answerMarkdownView") as? MarkdownView
        let questionTitleLabel = previewVC.value(forKey: "questionTitleLabel") as? UILabel
        let answerTitleLabel = previewVC.value(forKey: "answerTitleLabel") as? UILabel
        
        XCTAssertNotNil(scrollView)
        XCTAssertNotNil(contentView)
        XCTAssertNotNil(questionMarkdownView)
        XCTAssertNotNil(answerMarkdownView)
        XCTAssertNotNil(questionTitleLabel)
        XCTAssertNotNil(answerTitleLabel)
        
        // 测试标题文本
        XCTAssertEqual(questionTitleLabel?.text, "问题")
        XCTAssertEqual(answerTitleLabel?.text, "答案")
    }
    
    func testEmotionLabelVisibility() {
        // 测试情感标签在情感分析开启时可见
        let emotionLabelWithEmotion = previewVC.value(forKey: "emotionLabel") as? UILabel
        XCTAssertNotNil(emotionLabelWithEmotion)
        XCTAssertFalse(emotionLabelWithEmotion?.isHidden ?? true)
        
        // 创建情感分析关闭的预览控制器
        let previewVCNoEmotion = PreviewViewController(questionText: testQuestion, answerText: testAnswer, isColorEnabled: false)
        _ = previewVCNoEmotion.view // 加载视图
        
        // 验证情感标签在情感分析关闭时不应显示
        let emotionLabel = previewVCNoEmotion.value(forKey: "emotionLabel") as? UILabel
        if let label = emotionLabel {
            // 标签存在但应该被隐藏或不在视图层次结构中
            let isInViewHierarchy = label.superview != nil
            XCTAssertFalse(isInViewHierarchy, "情感分析关闭时情感标签不应该添加到视图")
        }
    }
    
    func testNavigationBarButtons() {
        // 测试导航栏按钮是否存在
        XCTAssertNotNil(previewVC.navigationItem.leftBarButtonItem)
        XCTAssertNotNil(previewVC.navigationItem.rightBarButtonItem)
        
        XCTAssertEqual(previewVC.navigationItem.leftBarButtonItem?.title, "返回")
        XCTAssertEqual(previewVC.navigationItem.rightBarButtonItem?.title, "保存")
    }
} 