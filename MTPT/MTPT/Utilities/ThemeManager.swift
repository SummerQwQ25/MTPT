import UIKit
import NaturalLanguage

enum EmotionType {
  case positive
  case negative
  case neutral
  
  var description: String {
    switch self {
    case .positive: return "Positive"
    case .negative: return "Negative"
    case .neutral: return "Neutral"
    }
  }
}

struct ThemeColors {
  let background: UIColor
  let titleText: UIColor
  let contentBackground: UIColor
  let contentText: UIColor
  let borderColor: UIColor
  
  // 预定义主题
  static let positive = ThemeColors(
    background: UIColor(red: 0.95, green: 1.0, blue: 0.95, alpha: 1.0),
    titleText: UIColor(red: 0.0, green: 0.5, blue: 0.3, alpha: 1.0),
    contentBackground: UIColor(red: 0.9, green: 1.0, blue: 0.9, alpha: 1.0),
    contentText: UIColor(red: 0.0, green: 0.4, blue: 0.2, alpha: 1.0),
    borderColor: UIColor(red: 0.7, green: 0.9, blue: 0.7, alpha: 1.0)
  )
  
  static let negative = ThemeColors(
    background: UIColor(red: 0.98, green: 0.95, blue: 0.95, alpha: 1.0),
    titleText: UIColor(red: 0.6, green: 0.1, blue: 0.1, alpha: 1.0),
    contentBackground: UIColor(red: 0.95, green: 0.92, blue: 0.92, alpha: 1.0),
    contentText: UIColor(red: 0.5, green: 0.1, blue: 0.1, alpha: 1.0),
    borderColor: UIColor(red: 0.9, green: 0.8, blue: 0.8, alpha: 1.0)
  )
  
  static let neutral = ThemeColors(
    background: UIColor(red: 0.95, green: 0.95, blue: 1.0, alpha: 1.0),
    titleText: UIColor(red: 0.1, green: 0.1, blue: 0.5, alpha: 1.0),
    contentBackground: UIColor(red: 0.92, green: 0.92, blue: 0.98, alpha: 1.0),
    contentText: UIColor(red: 0.1, green: 0.1, blue: 0.6, alpha: 1.0),
    borderColor: UIColor(red: 0.8, green: 0.8, blue: 0.9, alpha: 1.0)
  )
}

class ThemeManager {
  
  static let shared = ThemeManager()
  
  // 创建中文情感分析器
  private let sentimentAnalyzer = ChineseSentimentAnalyzer()
  
  private init() {}
  
  // 情感分析方法
  func analyzeEmotion(text: String) -> EmotionType {
    // 使用专为中文优化的情感分析器
    return sentimentAnalyzer.analyze(text: text)
  }
  
  // 根据问题和答案的情感选择主题
  func selectTheme(questionText: String, answerText: String) -> ThemeColors {
    // 分析问题和答案的情感
    let questionEmotion = analyzeEmotion(text: questionText)
    let answerEmotion = analyzeEmotion(text: answerText)
    
    // 打印调试信息
    print("问题情绪: \(questionEmotion.description)")
    print("答案情绪: \(answerEmotion.description)")
    
    // 简单策略：优先考虑答案的情感，因为通常答案更长更具表现力
    // 如果答案是中性的，则考虑问题的情感
    switch answerEmotion {
    case .positive:
      return ThemeColors.positive
    case .negative:
      return ThemeColors.negative
    case .neutral:
      // 如果答案是中性的，查看问题的情感
      switch questionEmotion {
      case .positive:
        return ThemeColors.positive
      case .negative:
        return ThemeColors.negative
      case .neutral:
        return ThemeColors.neutral
      }
    }
  }
}
