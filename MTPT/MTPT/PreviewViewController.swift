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
    applyThemeBasedOnContent()
    loadMarkdownContent()
    enableSwipeBackGesture()
  }
  
  private func setupUI() {
    title = "预览"
    view.backgroundColor = .white
    
    // 添加返回按钮
    navigationItem.leftBarButtonItem = UIBarButtonItem(
      title: "返回",
      style: .plain,
      target: self,
      action: #selector(dismissPreview)
    )
    
    // 添加保存按钮
    navigationItem.rightBarButtonItem = UIBarButtonItem(
      title: "保存",
      style: .plain,
      target: self,
      action: #selector(saveImage)
    )
    
    // 设置 ScrollView
    view.addSubview(scrollView)
    scrollView.snp.makeConstraints { make in
      make.edges.equalToSuperview()
    }
    
    // 设置 ContentView
    scrollView.addSubview(contentView)
    contentView.snp.makeConstraints { make in
      make.edges.equalToSuperview()
      make.width.equalTo(scrollView)
    }
    
    // 问题标题
    questionTitleLabel.text = "问题"
    questionTitleLabel.font = .boldSystemFont(ofSize: 18)
    contentView.addSubview(questionTitleLabel)
    questionTitleLabel.snp.makeConstraints { make in
      make.top.equalToSuperview().offset(20)
      make.leading.equalToSuperview().offset(20)
      make.trailing.equalToSuperview().offset(-20)
    }
    
    // 问题 Markdown 视图
    contentView.addSubview(questionMarkdownView)
    questionMarkdownView.snp.makeConstraints { make in
      make.top.equalTo(questionTitleLabel.snp.bottom).offset(10)
      make.leading.equalToSuperview().offset(20)
      make.trailing.equalToSuperview().offset(-20)
      // 保存高度约束的引用以便后续更新
      questionMarkdownViewHeight = make.height.equalTo(50).constraint    // 初始高度
    }
    
    // 答案标题
    answerTitleLabel.text = "答案"
    answerTitleLabel.font = .boldSystemFont(ofSize: 18)
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
      make.bottom.equalToSuperview().offset(-30)
    }
    
    // 禁用滚动，以便获取完整内容
    questionMarkdownView.isScrollEnabled = false
    answerMarkdownView.isScrollEnabled = false
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
    let loadingAlert = UIAlertController(title: "处理中", message: "正在生成图片...", preferredStyle: .alert)
    present(loadingAlert, animated: true)
    
    // 获取当前主题（用于保存带情感色彩的图片）
    let theme = ThemeManager.shared.selectTheme(questionText: questionText, answerText: answerText)
    
    // 生成截图
    generateTextImage(withTheme: theme, isColorEnabled: isColorEnabled) { image in
        loadingAlert.dismiss(animated: true) {
            if let image = image {
                // 图片生成成功，保存到相册
                UIImageWriteToSavedPhotosAlbum(image, self, #selector(self.image(_:didFinishSavingWithError:contextInfo:)), nil)
            } else {
                // 截图失败
                self.showAlert(title: "截图失败", message: "无法生成图片，请稍后再试")
            }
        }
    }
  }
  
  private func generateTextImage(withTheme theme: ThemeColors, isColorEnabled: Bool, completion: @escaping (UIImage?) -> Void) {
    let defaultContentText = UIColor.black
    let defaultTitleText = UIColor.black
    let defaultBackground = UIColor.white
    let defaultContentBackground = UIColor.white
    
    let questionAttributes: [NSAttributedString.Key: Any] = [
        .font: UIFont.systemFont(ofSize: 16),
        .foregroundColor: isColorEnabled ? theme.contentText : defaultContentText
    ]
    let questionTitleAttributes: [NSAttributedString.Key: Any] = [
        .font: UIFont.boldSystemFont(ofSize: 18),
        .foregroundColor: isColorEnabled ? theme.titleText : defaultTitleText
    ]
    
    // 固定页面宽度和边距
    let pageWidth: CGFloat = UIScreen.main.bounds.width - 40
    let margin: CGFloat = 20
    let padding: CGFloat = 8  // 添加内边距
    
    // 计算问题文本的大小
    let questionTitle = NSAttributedString(string: "问题", attributes: questionTitleAttributes)
    let questionString = NSAttributedString(string: questionText, attributes: questionAttributes)
    
    let questionTitleSize = questionTitle.boundingRect(
        with: CGSize(width: pageWidth, height: .greatestFiniteMagnitude),
        options: [.usesLineFragmentOrigin, .usesFontLeading],
        context: nil
    ).size
    
    let questionSize = questionString.boundingRect(
        with: CGSize(width: pageWidth - padding*2, height: .greatestFiniteMagnitude),
        options: [.usesLineFragmentOrigin, .usesFontLeading],
        context: nil
    ).size
    
    // 答案部分
    let answerTitle = NSAttributedString(string: "答案", attributes: questionTitleAttributes)
    let answerString = NSAttributedString(string: answerText, attributes: questionAttributes)
    
    let answerTitleSize = answerTitle.boundingRect(
        with: CGSize(width: pageWidth, height: .greatestFiniteMagnitude),
        options: [.usesLineFragmentOrigin, .usesFontLeading],
        context: nil
    ).size
    
    let answerSize = answerString.boundingRect(
        with: CGSize(width: pageWidth - padding*2, height: .greatestFiniteMagnitude),
        options: [.usesLineFragmentOrigin, .usesFontLeading],
        context: nil
    ).size
    
    // 计算内容位置
    let questionTitleY = margin
    let questionBoxY = questionTitleY + questionTitleSize.height + margin/2
    let questionContentY = questionBoxY + padding
    
    let answerTitleY = questionBoxY + questionSize.height + padding*2 + margin
    let answerBoxY = answerTitleY + answerTitleSize.height + margin/2
    let answerContentY = answerBoxY + padding
    
    // 计算图像总高度
    let totalHeight = answerBoxY + answerSize.height + padding*2 + margin
    
    // 创建绘图上下文
    UIGraphicsBeginImageContextWithOptions(CGSize(width: UIScreen.main.bounds.width, height: totalHeight), false, UIScreen.main.scale)
    guard let context = UIGraphicsGetCurrentContext() else {
        UIGraphicsEndImageContext()
        completion(nil)
        return
    }
    
    let contentBackgroundColor = isColorEnabled ? theme.contentBackground : defaultContentBackground
    
    context.setFillColor((isColorEnabled ? theme.background : defaultBackground).cgColor)
    
    // 填充背景色才·
    context.fill(CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: totalHeight))
    
    // 绘制问题内容框背景
    context.setFillColor(contentBackgroundColor.cgColor)
    let questionBoxRect = CGRect(
        x: margin/2, 
        y: questionBoxY, 
        width: UIScreen.main.bounds.width - margin, 
        height: questionSize.height + padding*2
    )
    let questionPath = UIBezierPath(roundedRect: questionBoxRect, cornerRadius: 8)
    context.addPath(questionPath.cgPath)
    context.fillPath()
    
    // 绘制答案内容框背景
    context.setFillColor(contentBackgroundColor.cgColor)
    let answerBoxRect = CGRect(
        x: margin/2, 
        y: answerBoxY, 
        width: UIScreen.main.bounds.width - margin, 
        height: answerSize.height + padding*2
    )
    let answerPath = UIBezierPath(roundedRect: answerBoxRect, cornerRadius: 8)
    context.addPath(answerPath.cgPath)
    context.fillPath()
    
    // 绘制问题标题
    questionTitle.draw(at: CGPoint(x: margin, y: questionTitleY))
    
    // 绘制问题内容 - 位置调整考虑内边距
    questionString.draw(in: CGRect(x: margin + padding, y: questionContentY, width: pageWidth - padding*2, height: questionSize.height))
    
    // 绘制答案标题
    answerTitle.draw(at: CGPoint(x: margin, y: answerTitleY))
    
    // 绘制答案内容 - 位置调整考虑内边距
    answerString.draw(in: CGRect(x: margin + padding, y: answerContentY, width: pageWidth - padding*2, height: answerSize.height))
    
    // 获取生成的图像
    let image = UIGraphicsGetImageFromCurrentImageContext()
    UIGraphicsEndImageContext()
    
    // 返回结果
    completion(image)
  }
  
  private func showAlert(title: String, message: String) {
    let alertController = UIAlertController(
      title: title,
      message: message,
      preferredStyle: .alert
    )
    alertController.addAction(UIAlertAction(title: "好的", style: .default))
    present(alertController, animated: true)
  }
  
  @objc private func image(_ image: UIImage, didFinishSavingWithError error: Error?, contextInfo: UnsafeRawPointer) {
    if let error = error {
      // 保存失败
      let alertController = UIAlertController(
        title: "保存失败",
        message: error.localizedDescription,
        preferredStyle: .alert
      )
      alertController.addAction(UIAlertAction(title: "好的", style: .default))
      present(alertController, animated: true)
    } else {
      // 保存成功
      let alertController = UIAlertController(
        title: "保存成功",
        message: "图片已保存到相册",
        preferredStyle: .alert
      )
      alertController.addAction(UIAlertAction(title: "好的", style: .default))
      present(alertController, animated: true)
    }
  }
  
  private func enableSwipeBackGesture() {
    // 确保右滑返回手势有效
    if let navigationController = navigationController {
      // 启用滑动返回手势
      navigationController.interactivePopGestureRecognizer?.isEnabled = true
      
      // 设置滑动手势代理 (如果需要)
      navigationController.interactivePopGestureRecognizer?.delegate = nil
      
      // 确保滑动手势有效区域
      scrollView.panGestureRecognizer.require(toFail: navigationController.interactivePopGestureRecognizer!)
    }
  }
  
  private func applyThemeBasedOnContent() {
    guard isColorEnabled else {
        view.backgroundColor = .white
        contentView.backgroundColor = .white
        scrollView.backgroundColor = .white
        questionTitleLabel.textColor = .black
        answerTitleLabel.textColor = .black
        return
    }
    
    let theme = ThemeManager.shared.selectTheme(questionText: questionText, answerText: answerText)
    
    let toast = UIAlertController(title: "AI主题", message: "正在应用智能配色...", preferredStyle: .alert)
    present(toast, animated: true)
    
    DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { [weak self] in
      guard let self = self else { return }
      
      self.view.backgroundColor = theme.background
      self.contentView.backgroundColor = theme.background
      self.scrollView.backgroundColor = theme.background
      
      self.questionTitleLabel.textColor = theme.titleText
      self.answerTitleLabel.textColor = theme.titleText
      
      // MarkdownView 样式
      // 由于MarkdownView是WebView，需要通过JavaScript注入CSS
      let cssStyle = """
                body { 
                    background-color: \(self.hexString(from: theme.contentBackground)) !important; 
                    color: \(self.hexString(from: theme.contentText)) !important; 
                }
                code {
                    background-color: \(self.hexString(from: theme.borderColor)) !important;
                }
            """
      
      self.questionMarkdownView.load(markdown: self.questionText, css: cssStyle)
      self.answerMarkdownView.load(markdown: self.answerText, css: cssStyle)
      
      // 关闭提示
      toast.dismiss(animated: true) {
        // 显示应用了什么主题
        let emotion = ThemeManager.shared.analyzeEmotion(text: self.answerText)
        self.showToast(message: "已应用\(emotion.description)情绪主题")
      }
    }
  }
  
  private func hexString(from color: UIColor) -> String {
    var r: CGFloat = 0
    var g: CGFloat = 0
    var b: CGFloat = 0
    var a: CGFloat = 0
    
    color.getRed(&r, green: &g, blue: &b, alpha: &a)
    
    return String(
      format: "#%02X%02X%02X",
      Int(r * 255),
      Int(g * 255),
      Int(b * 255)
    )
  }
  
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
    
    toastLabel.frame = CGRect(
      x: view.frame.width/2 - labelWidth/2,
      y: view.frame.height/2 - labelHeight/2,
      width: labelWidth,
      height: labelHeight
    )
    
    view.addSubview(toastLabel)
    
    UIView.animate(withDuration: 0.5, delay: 1.5, options: .curveEaseOut, animations: {
      toastLabel.alpha = 0.0
    }, completion: { _ in
      toastLabel.removeFromSuperview()
    })
  }
}
