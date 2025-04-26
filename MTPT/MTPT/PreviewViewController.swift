import UIKit
import SnapKit
import MarkdownView
import WebKit

class PreviewViewController: UIViewController {
  
  // UI 组件
  private let scrollView = UIScrollView()
  private let contentView = UIView()
  private let questionMarkdownView = MarkdownView()
  private let answerMarkdownView = MarkdownView()
  private let questionTitleLabel = UILabel()
  private let answerTitleLabel = UILabel()
  private let emotionLabel = UILabel() // 添加情绪标签
  
  // 内容
  private var questionText: String
  private var answerText: String
  
  // 添加高度约束变量
  private var questionMarkdownViewHeight: Constraint?
  private var answerMarkdownViewHeight: Constraint?
  private var markdownsRendered = 0
  
  private var isContentReady: Bool {
    return markdownsRendered >= 2  // 两个 MarkdownView 都加载完成
  }
  
  // 是否启用颜色 (只用于存储状态，不再影响UI)
  private var isColorEnabled: Bool
  
  // 初始化方法，传入问题和答案内容
  init(questionText: String, answerText: String, isColorEnabled: Bool) {
    self.questionText = questionText
    self.answerText = answerText
    self.isColorEnabled = isColorEnabled
    super.init(nibName: nil, bundle: nil)
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    setupUI()
    addEmotionLabel() // 添加情绪标签
    loadMarkdownContent()
    enableSwipeBackGesture()
  }
  
  private func setupUI() {
    title = "Preview"
    view.backgroundColor = .white
    
    // 添加返回按钮
    navigationItem.leftBarButtonItem = UIBarButtonItem(
      title: "Back",
      style: .plain,
      target: self,
      action: #selector(dismissPreview)
    )
    
    // 添加保存按钮
    navigationItem.rightBarButtonItem = UIBarButtonItem(
      title: "Save",
      style: .plain,
      target: self,
      action: #selector(saveImage)
    )
    
    // 设置滚动视图
    view.addSubview(scrollView)
    scrollView.snp.makeConstraints { make in
      make.edges.equalTo(view.safeAreaLayoutGuide)
    }
    
    // 内容视图
    scrollView.addSubview(contentView)
    contentView.snp.makeConstraints { make in
      make.edges.equalToSuperview()
      make.width.equalToSuperview()
      // 这里不设置高度，由内容决定
    }
    
    // 问题标题
    questionTitleLabel.text = "Question"
    questionTitleLabel.font = .boldSystemFont(ofSize: 18)
    questionTitleLabel.textColor = .black
    contentView.addSubview(questionTitleLabel)
    questionTitleLabel.snp.makeConstraints { make in
      make.top.equalToSuperview().offset(20)
      make.leading.equalToSuperview().offset(20)
      make.trailing.equalToSuperview().offset(-20)
    }
    
    // 问题 Markdown 视图
    questionMarkdownView.isOpaque = false
    questionMarkdownView.backgroundColor = .clear
    contentView.addSubview(questionMarkdownView)
    questionMarkdownView.snp.makeConstraints { make in
      make.top.equalTo(questionTitleLabel.snp.bottom).offset(10)
      make.leading.equalToSuperview().offset(20)
      make.trailing.equalToSuperview().offset(-20)
      // 保存高度约束的引用以便后续更新
      questionMarkdownViewHeight = make.height.equalTo(50).constraint    // 初始高度
    }
    
    // 答案标题
    answerTitleLabel.text = "Answer"
    answerTitleLabel.font = .boldSystemFont(ofSize: 18)
    answerTitleLabel.textColor = .black
    contentView.addSubview(answerTitleLabel)
    answerTitleLabel.snp.makeConstraints { make in
      make.top.equalTo(questionMarkdownView.snp.bottom).offset(30)
      make.leading.equalToSuperview().offset(20)
      make.trailing.equalToSuperview().offset(-20)
    }
    
    // 答案 Markdown 视图
    contentView.addSubview(answerMarkdownView)
    answerMarkdownView.snp.makeConstraints { make in
      make.top.equalTo(answerTitleLabel.snp.bottom).offset(10)
      make.leading.equalToSuperview().offset(20)
      make.trailing.equalToSuperview().offset(-20)
      // 保存高度约束的引用以便后续更新
      answerMarkdownViewHeight = make.height.equalTo(50).constraint    // 初始高度
    }
    
    // 禁用滚动，以便获取完整内容
    questionMarkdownView.isScrollEnabled = false
    answerMarkdownView.isScrollEnabled = false
  }
  
  // 添加情绪标签
  private func addEmotionLabel() {
    // 无论是否显示情感标签，都需要确保有正确的底部约束
    if isColorEnabled {
        // 用户启用了情感分析，添加标签
        emotionLabel.font = .italicSystemFont(ofSize: 12)
        emotionLabel.textColor = .gray
        emotionLabel.textAlignment = .right
        
        // 分析情感
        let emotion = ThemeManager.shared.analyzeEmotion(text: answerText)
        emotionLabel.text = "Emotional Analysis: \(emotion.description)"
        
        contentView.addSubview(emotionLabel)
        emotionLabel.snp.makeConstraints { make in
            make.top.equalTo(answerMarkdownView.snp.bottom).offset(10)
            make.trailing.equalToSuperview().offset(-20)
            make.bottom.equalToSuperview().offset(-10)
        }
    } else {
        // 用户关闭了情感分析，不添加标签，但需要添加底部约束
        // 为 answerMarkdownView 添加底部约束
        answerMarkdownView.snp.makeConstraints { make in
            make.bottom.equalToSuperview().offset(-20)
        }
    }
  }
  
  private func loadMarkdownContent() {
    // 设置加载完成回调
    questionMarkdownView.onRendered = { [weak self] height in
      guard let self = self else { return }
      print("问题 Markdown 渲染完成，高度: \(height)")
      
      // 更新高度约束
      self.questionMarkdownViewHeight?.update(offset: height)
      
      // 记录渲染完成状态
      self.markdownsRendered += 1
      
      // 强制布局更新
      self.view.setNeedsLayout()
      self.view.layoutIfNeeded()
    }
    
    answerMarkdownView.onRendered = { [weak self] height in
      guard let self = self else { return }
      print("答案 Markdown 渲染完成，高度: \(height)")
      
      // 更新高度约束
      self.answerMarkdownViewHeight?.update(offset: height)
      
      // 记录渲染完成状态
      self.markdownsRendered += 1
      
      // 强制布局更新
      self.view.setNeedsLayout()
      self.view.layoutIfNeeded()
    }
    
    // 加载 Markdown 内容
    questionMarkdownView.load(markdown: questionText)
    answerMarkdownView.load(markdown: answerText)
  }
  
  @objc private func dismissPreview() {
    navigationController?.popViewController(animated: true)
  }
  
  @objc private func saveImage() {
    // 显示一个加载指示器
    let loadingAlert = UIAlertController(title: "Processing", message: "The image is being generated...", preferredStyle: .alert)
    present(loadingAlert, animated: true)
    
    // 确保两个 markdown 视图都已经渲染完成
    if markdownsRendered < 2 {
        // 如果尚未完成渲染，等待一段时间后重试
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { [weak self] in
            loadingAlert.dismiss(animated: true) {
                self?.saveImage()
            }
        }
        return
    }
    
    // 使用 drawHierarchy 来生成完整内容截图
    DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) { [weak self] in
        guard let self = self else { return }
        
        // 保存原始滚动位置
        let originalOffset = self.scrollView.contentOffset
        
        // 获取完整内容大小
        let contentSize = self.scrollView.contentSize
        
        // 创建适当大小的位图上下文
        UIGraphicsBeginImageContextWithOptions(contentSize, false, UIScreen.main.scale)
        
        // 保存原始剪裁设置
        let oldClipsToBounds = self.scrollView.clipsToBounds
        self.scrollView.clipsToBounds = false
        
        // 处理每个子视图
        for subview in self.contentView.subviews {
            // 计算子视图在整个内容中的绝对位置
            let rect = subview.convert(subview.bounds, to: self.contentView)
            
            // 将每个子视图绘制到上下文
            if let context = UIGraphicsGetCurrentContext() {
                context.saveGState()
                context.translateBy(x: rect.origin.x, y: rect.origin.y)
                subview.layer.render(in: context)
                context.restoreGState()
            }
        }
        
        // 获取最终图像
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        // 恢复原始设置
        self.scrollView.clipsToBounds = oldClipsToBounds
        self.scrollView.setContentOffset(originalOffset, animated: false)
        
        // 处理生成的图像
        loadingAlert.dismiss(animated: true) {
            if let image = image {
                UIImageWriteToSavedPhotosAlbum(image, self, #selector(PreviewViewController.imageSaved(_:didFinishSavingWithError:contextInfo:)), nil)
            } else {
                // 截图失败
                self.showAlert(title: "The screenshot failed", message: "Unable to generate the image. Please try again later.")
            }
        }
    }
  }
  
  // 处理图片保存结果
  @objc func imageSaved(_ image: UIImage, didFinishSavingWithError error: Error?, contextInfo: UnsafeRawPointer) {
    if let error = error {
        // 保存失败
        let alertController = UIAlertController(
            title: "Save failed",
            message: error.localizedDescription,
            preferredStyle: .alert
        )
        alertController.addAction(UIAlertAction(title: "OK", style: .default))
        present(alertController, animated: true)
    } else {
        // 保存成功
        let alertController = UIAlertController(
            title: "Save successfully",
            message: "The image has been saved to the photo album.",
            preferredStyle: .alert
        )
        alertController.addAction(UIAlertAction(title: "OK", style: .default))
        present(alertController, animated: true)
    }
  }
  
  private func showAlert(title: String, message: String) {
    let alertController = UIAlertController(
      title: title,
      message: message,
      preferredStyle: .alert
    )
    alertController.addAction(UIAlertAction(title: "OK", style: .default))
    present(alertController, animated: true)
  }
  
  private func enableSwipeBackGesture() {
    // 确保右滑返回手势有效
    if let navigationController = navigationController {
      // 启用滑动返回手势
      navigationController.interactivePopGestureRecognizer?.isEnabled = true
      
      // 设置滑动手势代理 (如果需要)
      navigationController.interactivePopGestureRecognizer?.delegate = nil
    }
  }
}

// 扩展 MarkdownView 来访问内部的 WebView
extension MarkdownView {
    var internalWebView: WKWebView? {
        return subviews.first as? WKWebView
    }
}
