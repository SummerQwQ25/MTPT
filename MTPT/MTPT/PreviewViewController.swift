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
    
    // 初始化方法，传入问题和答案内容
    init(questionText: String, answerText: String) {
        self.questionText = questionText
        self.answerText = answerText
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
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
        
        // 生成截图
        generateTextImage { image in
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
    
    private func generateTextImage(completion: @escaping (UIImage?) -> Void) {
        // 创建一个NSAttributedString来表示问题
        let questionAttributes: [NSAttributedString.Key: Any] = [
            .font: UIFont.systemFont(ofSize: 16),
            .foregroundColor: UIColor.black
        ]
        let questionTitleAttributes: [NSAttributedString.Key: Any] = [
            .font: UIFont.boldSystemFont(ofSize: 18),
            .foregroundColor: UIColor.black
        ]
        
        // 固定页面宽度和边距
        let pageWidth: CGFloat = UIScreen.main.bounds.width - 40
        let margin: CGFloat = 20
        
        // 计算问题文本的大小
        let questionTitle = NSAttributedString(string: "问题", attributes: questionTitleAttributes)
        let questionString = NSAttributedString(string: questionText, attributes: questionAttributes)
        
        let questionTitleSize = questionTitle.boundingRect(
            with: CGSize(width: pageWidth, height: .greatestFiniteMagnitude),
            options: [.usesLineFragmentOrigin, .usesFontLeading],
            context: nil
        ).size
        
        let questionSize = questionString.boundingRect(
            with: CGSize(width: pageWidth, height: .greatestFiniteMagnitude),
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
            with: CGSize(width: pageWidth, height: .greatestFiniteMagnitude),
            options: [.usesLineFragmentOrigin, .usesFontLeading],
            context: nil
        ).size
        
        // 计算图像总高度
        let totalHeight = margin + questionTitleSize.height + margin/2 + questionSize.height + 
                          margin + answerTitleSize.height + margin/2 + answerSize.height + margin
        
        // 创建绘图上下文
        UIGraphicsBeginImageContextWithOptions(CGSize(width: UIScreen.main.bounds.width, height: totalHeight), false, UIScreen.main.scale)
        guard let context = UIGraphicsGetCurrentContext() else {
            UIGraphicsEndImageContext()
            completion(nil)
            return
        }
        
        // 填充白色背景
        context.setFillColor(UIColor.white.cgColor)
        context.fill(CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: totalHeight))
        
        // 绘制问题标题
        var yPosition: CGFloat = margin
        questionTitle.draw(at: CGPoint(x: margin, y: yPosition))
        yPosition += questionTitleSize.height + margin/2
        
        // 绘制问题内容
        questionString.draw(in: CGRect(x: margin, y: yPosition, width: pageWidth, height: questionSize.height))
        yPosition += questionSize.height + margin
        
        // 绘制答案标题
        answerTitle.draw(at: CGPoint(x: margin, y: yPosition))
        yPosition += answerTitleSize.height + margin/2
        
        // 绘制答案内容
        answerString.draw(in: CGRect(x: margin, y: yPosition, width: pageWidth, height: answerSize.height))
        
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
} 
