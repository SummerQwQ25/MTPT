//
//  ViewController.swift
//  MTPT
//
//  Created by yan zheng on 2025/3/23.
//

import UIKit
import SnapKit
import Combine
import CombineCocoa

class ViewController: UIViewController, UITextViewDelegate {
  
  // UI 组件
  private let questionLabel = UILabel()
  private let questionTextView = UITextView()
  private let answerLabel = UILabel()
  private let answerTextView = UITextView()
  private let generateButton = UIButton(type: .system)
  private let clearButton = UIButton(type: .system)
  
  // Combine 相关
  private var cancellables = Set<AnyCancellable>()
  
  // Placeholder 文本
  private let questionPlaceholder = NSLocalizedString("please_enter_question", comment: "Placeholder for question field")
  private let answerPlaceholder = NSLocalizedString("please_enter_answer", comment: "Placeholder for answer field")
  
  // 添加手势识别器
  private lazy var tapGesture = UITapGestureRecognizer()

  override func viewDidLoad() {
    super.viewDidLoad()
    // 设置标题
    title = "MTPT"
    // 强制当前控制器使用浅色模式
    overrideUserInterfaceStyle = .light
    // Do any additional setup after loading the view.
    setupUI()
    setupBindings()
    setupPlaceholders()
    setupTapGesture()
    setupTextViewDelegates()
  }
  
  private func setupBindings() {
    // 使用 CombineCocoa 提供的扩展
    generateButton.tapPublisher
      .sink { [weak self] in
        self?.generateImage()
      }
      .store(in: &cancellables)
    
    clearButton.tapPublisher
      .sink { [weak self] in
        self?.clearAll()
      }
      .store(in: &cancellables)
    
    // 监听 TextView 的文本变化
    questionTextView.textPublisher
      .sink { [weak self] text in
        guard let self = self else { return }
        if text.isNilOrEmpty || text == self.questionPlaceholder {
          if questionTextView.isFirstResponder {
            questionTextView.textColor = .black
          } else {
            self.setupQuestionPlaceholder()
          }
        } else {
          questionTextView.textColor = .black
        }
      }
      .store(in: &cancellables)
    
    answerTextView.textPublisher
      .sink { [weak self] text in
        guard let self = self else { return }
        if text.isNilOrEmpty || text == self.answerPlaceholder {
          if answerTextView.isFirstResponder {
            answerTextView.textColor = .black
          } else {
            self.setupAnswerPlaceholder()
          }
        } else {
          answerTextView.textColor = .black
        }
      }
      .store(in: &cancellables)
  }
  
  private func setupPlaceholders() {
    // 设置初始占位文本
    setupQuestionPlaceholder()
    setupAnswerPlaceholder()
    
    // 添加 UITextView 的 begin/end editing 通知监听
    NotificationCenter.default.publisher(for: UITextView.textDidBeginEditingNotification, object: questionTextView)
      .sink { [weak self] _ in
        guard let self = self else { return }
        if self.questionTextView.text == self.questionPlaceholder {
          self.questionTextView.text = ""
          self.questionTextView.textColor = .black
        }
      }
      .store(in: &cancellables)
    
    NotificationCenter.default.publisher(for: UITextView.textDidEndEditingNotification, object: questionTextView)
      .sink { [weak self] _ in
        guard let self = self else { return }
        if self.questionTextView.text.isEmpty {
          self.setupQuestionPlaceholder()
        }
      }
      .store(in: &cancellables)
    
    NotificationCenter.default.publisher(for: UITextView.textDidBeginEditingNotification, object: answerTextView)
      .sink { [weak self] _ in
        guard let self = self else { return }
        if self.answerTextView.text == self.answerPlaceholder {
          self.answerTextView.text = ""
          self.answerTextView.textColor = .black
        }
      }
      .store(in: &cancellables)
    
    NotificationCenter.default.publisher(for: UITextView.textDidEndEditingNotification, object: answerTextView)
      .sink { [weak self] _ in
        guard let self = self else { return }
        if self.answerTextView.text.isEmpty {
          self.setupAnswerPlaceholder()
        }
      }
      .store(in: &cancellables)
  }
  
  private func setupQuestionPlaceholder() {
    questionTextView.text = questionPlaceholder
    questionTextView.textColor = .lightGray
  }
  
  private func setupAnswerPlaceholder() {
    answerTextView.text = answerPlaceholder
    answerTextView.textColor = .lightGray
  }
  
  private func setupUI() {
    view.backgroundColor = .white
    
    // 设置问题标签
    questionLabel.text = NSLocalizedString("question", comment: "Question label")
    questionLabel.font = .boldSystemFont(ofSize: 16)
    view.addSubview(questionLabel)
    
    // 设置问题输入框
    questionTextView.layer.borderColor = UIColor.lightGray.cgColor
    questionTextView.layer.borderWidth = 1
    questionTextView.layer.cornerRadius = 5
    questionTextView.font = .systemFont(ofSize: 14)
    view.addSubview(questionTextView)
    
    // 设置约束
    questionLabel.snp.makeConstraints { make in
      make.top.equalTo(view.safeAreaLayoutGuide).offset(20)
      make.leading.equalToSuperview().offset(20)
      make.trailing.equalToSuperview().offset(-20)
    }
    
    questionTextView.snp.makeConstraints { make in
      make.top.equalTo(questionLabel.snp.bottom).offset(8)
      make.leading.equalToSuperview().offset(20)
      make.trailing.equalToSuperview().offset(-20)
      make.height.equalTo(150)
    }
    
    answerLabel.text = NSLocalizedString("answer", comment: "Answer label")
    answerLabel.font = .boldSystemFont(ofSize: 16)
    view.addSubview(answerLabel)
    
    answerLabel.snp.makeConstraints { make in
      make.top.equalTo(questionTextView.snp.bottom).offset(20)
      make.leading.equalToSuperview().offset(20)
      make.trailing.equalToSuperview().offset(-20)
    }
    
    answerTextView.layer.borderColor = UIColor.lightGray.cgColor
    answerTextView.layer.borderWidth = 1
    answerTextView.layer.cornerRadius = 5
    answerTextView.font = .systemFont(ofSize: 14)
    view.addSubview(answerTextView)
    
    answerTextView.snp.makeConstraints { make in
      make.top.equalTo(answerLabel.snp.bottom).offset(8)
      make.leading.equalToSuperview().offset(20)
      make.trailing.equalToSuperview().offset(-20)
      make.height.equalTo(150)
    }
    
    generateButton.setTitle(NSLocalizedString("preview", comment: "Preview button"), for: .normal)
    generateButton.backgroundColor = .black
    generateButton.setTitleColor(.white, for: .normal)
    generateButton.layer.cornerRadius = 5
    view.addSubview(generateButton)
    
    generateButton.snp.makeConstraints { make in
      make.top.equalTo(answerTextView.snp.bottom).offset(30)
      make.leading.equalToSuperview().offset(20)
      make.width.equalToSuperview().multipliedBy(0.42)
      make.height.equalTo(44)
    }
    
    clearButton.setTitle(NSLocalizedString("clear", comment: "Clear button"), for: .normal)
    clearButton.backgroundColor = .systemGray
    clearButton.setTitleColor(.white, for: .normal)
    clearButton.layer.cornerRadius = 5
    view.addSubview(clearButton)
    
    clearButton.snp.makeConstraints { make in
      make.top.equalTo(answerTextView.snp.bottom).offset(30)
      make.trailing.equalToSuperview().offset(-20)
      make.width.equalToSuperview().multipliedBy(0.42)
      make.height.equalTo(44)
      make.bottom.lessThanOrEqualTo(view.safeAreaLayoutGuide).offset(-20)
    }
  }
  
  private func generateImage() {
    // 获取问题和答案文本
    var questionText = questionTextView.text ?? ""
    var answerText = answerTextView.text ?? ""
    
    // 如果文本是占位符，则视为空字符串
    if questionText == questionPlaceholder {
      questionText = ""
    }
    
    if answerText == answerPlaceholder {
      answerText = ""
    }
    
    // 验证输入
    if questionText.isEmpty {
      showToast(message: NSLocalizedString("enter_question_warning", comment: "Warning for empty question"))
      return
    }
    
    if answerText.isEmpty {
      showToast(message: NSLocalizedString("enter_answer_warning", comment: "Warning for empty answer"))
      return
    }
    
    // 创建预览控制器并推送
    let previewVC = PreviewViewController(questionText: questionText, answerText: answerText)
    navigationController?.pushViewController(previewVC, animated: true)
  }
  
  private func clearAll() {
    // 清空问题和答案内容，并显示占位文本
    setupQuestionPlaceholder()
    setupAnswerPlaceholder()
  }
  
  private func setupTapGesture() {
    // 创建手势识别器
    let tapGesture = UITapGestureRecognizer()
    view.addGestureRecognizer(tapGesture)
    tapGesture.cancelsTouchesInView = false
    
    // 使用正确的选择器语法
    NotificationCenter.default.publisher(for: UIResponder.keyboardWillShowNotification)
      .sink { [weak self] _ in
        guard let self = self else { return }
        // 注册手势处理器
        tapGesture.addTarget(self, action: #selector(ViewController.handleTap))
      }
      .store(in: &cancellables)
    
    NotificationCenter.default.publisher(for: UIResponder.keyboardWillHideNotification)
      .sink { [weak self] _ in
        guard let self = self else { return }
        // 移除手势处理器，避免多次添加
        tapGesture.removeTarget(self, action: #selector(ViewController.handleTap))
      }
      .store(in: &cancellables)
  }
  
  @objc private func handleTap() {
    view.endEditing(true)
  }
  
  private func setupTextViewDelegates() {
    // 设置文本视图的代理
    questionTextView.delegate = self
    answerTextView.delegate = self
  }
  
  // MARK: - UITextViewDelegate
  
  func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
    // 检测是否是回车键
    if text == "\n" {
      // 收起键盘
      textView.resignFirstResponder()
      return false // 不添加换行符
    }
    return true // 允许其他文本输入
  }
  
  // 显示提示信息
  private func showToast(message: String) {
    let toastLabel = UILabel()
    toastLabel.backgroundColor = UIColor.black.withAlphaComponent(0.7)
    toastLabel.textColor = UIColor.white
    toastLabel.textAlignment = .center
    toastLabel.font = UIFont.systemFont(ofSize: 14)
    toastLabel.text = message
    toastLabel.alpha = 1.0
    toastLabel.layer.cornerRadius = 10
    toastLabel.clipsToBounds = true
    
    let textSize = toastLabel.intrinsicContentSize
    let labelWidth = min(textSize.width + 40, view.frame.width - 40)
    let labelHeight: CGFloat = 35
    
    // 设置标签居中位置
    toastLabel.frame = CGRect(
      x: view.frame.width/2 - labelWidth/2,
      y: view.frame.height/2 - labelHeight/2,
      width: labelWidth,
      height: labelHeight
    )
    
    view.addSubview(toastLabel)
    
    // 淡出动画
    UIView.animate(withDuration: 0.5, delay: 1.5, options: .curveEaseOut, animations: {
      toastLabel.alpha = 0.0
    }, completion: { _ in
      toastLabel.removeFromSuperview()
    })
  }
  
  deinit {
    // 清理 Combine 订阅
    cancellables.forEach { $0.cancel() }
    cancellables.removeAll()
  }
}

