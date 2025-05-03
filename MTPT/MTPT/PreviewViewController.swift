import UIKit
import SnapKit
import MarkdownView
import WebKit
import Photos

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
    // 强制当前控制器使用浅色模式
    overrideUserInterfaceStyle = .light
    
    // 设置导航栏返回按钮和标题为黑色
    if let navigationBar = navigationController?.navigationBar {
      navigationBar.tintColor = .black // 返回按钮颜色
      navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.black] // 标题颜色
    }
    
    setupUI()
    addEmotionLabel() // 添加情绪标签
    loadMarkdownContent()
    enableSwipeBackGesture()
  }
  
  private func setupUI() {
    title = NSLocalizedString("preview", comment: "Preview screen title")
    view.backgroundColor = .white
    
    // 不再添加自定义返回按钮，使用系统默认返回按钮
    
    // 添加保存按钮，使用黑色按钮样式
    let saveButton = UIButton(type: .system)
    saveButton.setTitle(NSLocalizedString("save", comment: "Save button"), for: .normal)
    saveButton.setTitleColor(.white, for: .normal)
    saveButton.backgroundColor = .black
    saveButton.layer.cornerRadius = 5
    saveButton.contentEdgeInsets = UIEdgeInsets(top: 5, left: 10, bottom: 5, right: 10)
    saveButton.addTarget(self, action: #selector(saveImage), for: .touchUpInside)
    
    let customBarItem = UIBarButtonItem(customView: saveButton)
    navigationItem.rightBarButtonItem = customBarItem
    
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
    questionTitleLabel.text = NSLocalizedString("question", comment: "Question label")
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
    answerTitleLabel.text = NSLocalizedString("answer", comment: "Answer label")
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
        let emotionText = String(format: NSLocalizedString("emotional_analysis", comment: "Emotional analysis label"), emotion.description)
        emotionLabel.text = emotionText
        
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
  
  @objc private func saveImage() {
    // 首先检查相册权限状态
    let status = PHPhotoLibrary.authorizationStatus()
    
    // 检查当前语言是否为中文
    let isChinese = Locale.current.languageCode == "zh"
    
    switch status {
    case .authorized, .limited:
      // 已授权，继续保存图片流程
      self.proceedWithImageSaving()
      
    case .denied, .restricted:
      // 权限被拒绝或受限，引导用户前往设置
      let title = isChinese ? "无法访问相册" : "Photo Access Denied"
      let message = isChinese ? "请在设置中开启相册访问权限，以便保存图片" : "Please enable photo access in Settings to save images"
      let cancelText = isChinese ? "取消" : "Cancel"
      let settingsText = isChinese ? "去设置" : "Settings"
      
      let alertController = UIAlertController(
        title: title,
        message: message,
        preferredStyle: .alert
      )
      
      // 添加"取消"按钮
      alertController.addAction(UIAlertAction(
        title: cancelText,
        style: .cancel
      ))
      
      // 添加"设置"按钮
      alertController.addAction(UIAlertAction(
        title: settingsText,
        style: .default
      ) { _ in
        if let url = URL(string: UIApplication.openSettingsURLString) {
          UIApplication.shared.open(url)
        }
      })
      
      present(alertController, animated: true)
      
    case .notDetermined:
      // 权限尚未确定，直接请求系统权限
      PHPhotoLibrary.requestAuthorization { [weak self] status in
        DispatchQueue.main.async {
          if status == .authorized || status == .limited {
            self?.proceedWithImageSaving()
          } else if status == .denied || status == .restricted {
            // 如果被拒绝，提示用户前往设置
            let title = isChinese ? "无法访问相册" : "Photo Access Denied"
            let message = isChinese ? "请在设置中开启相册访问权限，以便保存图片" : "Please enable photo access in Settings to save images"
            let cancelText = isChinese ? "取消" : "Cancel"
            let settingsText = isChinese ? "去设置" : "Settings"
            
            let alertController = UIAlertController(
              title: title,
              message: message,
              preferredStyle: .alert
            )
            
            // 添加"取消"按钮
            alertController.addAction(UIAlertAction(
              title: cancelText,
              style: .cancel
            ))
            
            // 添加"设置"按钮
            alertController.addAction(UIAlertAction(
              title: settingsText,
              style: .default
            ) { _ in
              if let url = URL(string: UIApplication.openSettingsURLString) {
                UIApplication.shared.open(url)
              }
            })
            
            self?.present(alertController, animated: true)
          }
        }
      }
      
    @unknown default:
      self.proceedWithImageSaving()
    }
  }
  
  // 将原始的保存图片逻辑提取到这个方法中
  private func proceedWithImageSaving() {
    // 显示一个加载指示器
    let loadingAlert = UIAlertController(
      title: NSLocalizedString("processing", comment: "Processing title"),
      message: NSLocalizedString("generating_image", comment: "Image generation message"),
      preferredStyle: .alert
    )
    present(loadingAlert, animated: true)
    
    // 确保两个 markdown 视图都已经渲染完成
    if markdownsRendered < 2 {
      // 如果尚未完成渲染，等待一段时间后重试
      DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { [weak self] in
        loadingAlert.dismiss(animated: true) {
          self?.proceedWithImageSaving()
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
          self.showAlert(
            title: NSLocalizedString("screenshot_failed", comment: "Screenshot failed title"),
            message: NSLocalizedString("generate_image_error", comment: "Image generation error message")
          )
        }
      }
    }
  }
  
  // 处理图片保存结果
  @objc func imageSaved(_ image: UIImage, didFinishSavingWithError error: Error?, contextInfo: UnsafeRawPointer) {
    if let error = error {
        // 保存失败
        let alertController = UIAlertController(
            title: NSLocalizedString("save_failed", comment: "Save failed title"),
            message: error.localizedDescription,
            preferredStyle: .alert
        )
        alertController.addAction(UIAlertAction(title: NSLocalizedString("ok", comment: "OK button"), style: .default))
        present(alertController, animated: true)
    } else {
        // 保存成功
        let alertController = UIAlertController(
            title: NSLocalizedString("save_success", comment: "Save success title"),
            message: NSLocalizedString("saved_to_album", comment: "Saved to album message"),
            preferredStyle: .alert
        )
        alertController.addAction(UIAlertAction(title: NSLocalizedString("ok", comment: "OK button"), style: .default))
        present(alertController, animated: true)
    }
  }
  
  private func showAlert(title: String, message: String) {
    let alertController = UIAlertController(
      title: title,
      message: message,
      preferredStyle: .alert
    )
    alertController.addAction(UIAlertAction(title: NSLocalizedString("ok", comment: "OK button"), style: .default))
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
