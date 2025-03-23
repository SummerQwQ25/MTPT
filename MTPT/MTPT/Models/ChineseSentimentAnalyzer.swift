import Foundation

class ChineseSentimentAnalyzer {
    // 积极词汇词典
    private let positiveWords = [
        "好", "棒", "喜欢", "爱", "高兴", "快乐", "不错", "优秀", "满意", "开心", 
        "感谢", "谢谢", "赞", "厉害", "成功", "优秀", "精彩", "完美", "解决", "帮助",
        "顺利", "幸福", "美好", "舒适", "惊喜", "期待", "希望", "信心", "鼓励", "支持",
        "正确", "清晰", "明白", "理解", "合理", "推荐"
    ]
    
    // 消极词汇词典
    private let negativeWords = [
        "不好", "差", "失望", "讨厌", "恨", "难过", "伤心", "失望", "糟糕", "烦", 
        "担心", "焦虑", "愤怒", "痛苦", "失败", "错误", "问题", "麻烦", "困难", "遗憾",
        "可怕", "恐惧", "害怕", "危险", "怀疑", "不满", "抱怨", "不合理", "不清楚", "复杂",
        "困惑", "弄错", "缺点", "批评", "拒绝", "混乱"
    ]
    
    // 否定词，用于反转情感
    private let negationWords = ["不", "没", "无", "非", "莫", "别", "勿", "未", "反", "难", "否"]
    
    // 强化词，增强情感强度
    private let intensifiers = ["很", "非常", "太", "格外", "极其", "特别", "尤其", "相当", "十分", "更加"]
    
    // 分析文本情感
    func analyze(text: String) -> EmotionType {
        // 计算整体分数
        var score = 0
        
        // 检查积极词
        for word in positiveWords {
            if checkWordInContext(word: word, in: text) {
                score += 1
            }
        }
        
        // 检查消极词
        for word in negativeWords {
            if checkWordInContext(word: word, in: text) {
                score -= 1
            }
        }
        
        print("中文情感分析分数: \(score)")
        
        // 确定情感类型
        if score > 0 {
            return .positive
        } else if score < 0 {
            return .negative
        } else {
            return .neutral
        }
    }
    
    // 检查单词在上下文中的情感 (考虑否定词)
    private func checkWordInContext(word: String, in text: String) -> Bool {
        guard let range = text.range(of: word) else {
            return false
        }
        
        // 找到了关键词
        let wordStart = text.distance(from: text.startIndex, to: range.lowerBound)
        
        // 检查是否有否定词在前面
        let checkRange = max(0, wordStart - 5) // 检查前5个字符
        let preContext = String(text.prefix(wordStart))
        
        // 如果前面有否定词，情感被反转
        for negation in negationWords {
            if preContext.hasSuffix(negation) {
                return false // 关键词被否定了
            }
        }
        
        return true // 关键词有效
    }
} 