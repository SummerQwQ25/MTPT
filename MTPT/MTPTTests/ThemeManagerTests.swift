import XCTest
@testable import MTPT

class ThemeManagerTests: XCTestCase {
    
    func testEmotionAnalysis() {
        let positiveText = "这个功能非常好用，我很喜欢"
        let negativeText = "这个功能不好用，我很失望"
        let neutralText = "这是一个普通的描述"
        
        let positiveEmotion = ThemeManager.shared.analyzeEmotion(text: positiveText)
        let negativeEmotion = ThemeManager.shared.analyzeEmotion(text: negativeText)
        let neutralEmotion = ThemeManager.shared.analyzeEmotion(text: neutralText)
        
        XCTAssertEqual(positiveEmotion, .positive)
        XCTAssertEqual(negativeEmotion, .negative)
        XCTAssertEqual(neutralEmotion, .neutral)
    }
    
    func testThemeSelection() {
        let positiveQuestion = "这个功能有什么优点？"
        let positiveAnswer = "这个功能非常好用，提高了效率"
        
        let negativeQuestion = "这个功能有什么问题？"
        let negativeAnswer = "这个功能不够稳定，经常出错"
        
        let neutralQuestion = "这个功能怎么用？"
        let neutralAnswer = "点击按钮即可启动该功能"
        
        let positiveTheme = ThemeManager.shared.selectTheme(questionText: positiveQuestion, answerText: positiveAnswer)
        let negativeTheme = ThemeManager.shared.selectTheme(questionText: negativeQuestion, answerText: negativeAnswer)
        let mixedTheme1 = ThemeManager.shared.selectTheme(questionText: positiveQuestion, answerText: neutralAnswer)
        let mixedTheme2 = ThemeManager.shared.selectTheme(questionText: neutralQuestion, answerText: negativeAnswer)
        
        // 测试是否返回正确的主题
        XCTAssertEqual(positiveTheme.background, ThemeColors.positive.background)
        XCTAssertEqual(negativeTheme.background, ThemeColors.negative.background)
        XCTAssertEqual(mixedTheme1.background, ThemeColors.positive.background)
        XCTAssertEqual(mixedTheme2.background, ThemeColors.negative.background)
    }
} 