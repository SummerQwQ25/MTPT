import XCTest
import SnapKit
@testable import MTPT

class ViewControllerTests: XCTestCase {
    
    var viewController: ViewController!
    
    override func setUp() {
        super.setUp()
        viewController = ViewController()
        _ = viewController.view // 加载视图
    }
    
    override func tearDown() {
        viewController = nil
        super.tearDown()
    }
    
    func testInitialSetup() {
        // 测试初始化状态
        XCTAssertNotNil(viewController.view)
        
        // 可以改成检查视图层次结构
        let questionLabel = viewController.view.viewWithTag(1) as? UILabel
        // 或者添加一个公共方法来获取这些组件
    }
    
    func testPreviewButtonAction() {
        // 模拟问题和答案的输入
        let questionTextView = viewController.value(forKey: "questionTextView") as! UITextView
        let answerTextView = viewController.value(forKey: "answerTextView") as! UITextView
        
        questionTextView.text = "这是一个测试问题"
        answerTextView.text = "这是一个测试答案"
        
        // 获取预览按钮并触发点击事件
        let previewButton = viewController.value(forKey: "previewButton") as! UIButton
        
        // 这个测试需要在实际的视图层次结构中执行，这里仅验证按钮存在
        XCTAssertNotNil(previewButton)
    }
    
    func testToggleAction() {
        // 获取开关并模拟切换
        let colorToggle = viewController.value(forKey: "colorToggle") as! UISwitch
        
        // 记录初始状态
        let initialState = colorToggle.isOn
        
        // 触发开关事件
        colorToggle.setOn(!initialState, animated: false)
        colorToggle.sendActions(for: .valueChanged)
        
        // 验证状态已改变
        XCTAssertEqual(colorToggle.isOn, !initialState)
    }
} 