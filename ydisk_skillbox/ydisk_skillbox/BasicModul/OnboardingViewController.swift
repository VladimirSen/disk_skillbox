import UIKit

final class OnboardingViewController: UIViewController, UIScrollViewDelegate {
    lazy var nextButton: UIButton = {
        let button = UIButton()
        button.frame = CGRect(x: (view.frame.size.width - 320) / 2,
                              y: view.frame.size.height - 140,
                              width: 320,
                              height: 40)
        button.backgroundColor = .systemBlue
        button.setTitle("Далее".localized(), for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 10
        button.layer.masksToBounds = true
        if #available(iOS 14.0, *) {
            button.addAction(
                UIAction(
                    handler: { [weak self] _ in
                        self?.navigationController?.pushViewController(LoginViewController(), animated: true)
                    }),
                for: .touchUpInside)
        } else { button.addTarget(self, action: #selector(tapNextButton), for: .touchUpInside)
        }
        return button
    }()
    private lazy var scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.frame = CGRect(x: 0,
                                  y: 0,
                                  width: Int(view.frame.size.width),
                                  height: Int(view.frame.size.height))
        scrollView.isPagingEnabled = true
        scrollView.showsVerticalScrollIndicator = false
        scrollView.showsHorizontalScrollIndicator = false
        return scrollView
    }()
    private lazy var pageControl: UIPageControl = {
        let pageControl = UIPageControl()
        pageControl.frame = CGRect(x: (scrollView.frame.size.width - 200) / 2,
                                   y: scrollView.frame.size.height - 200,
                                   width: 200,
                                   height: 50)
        pageControl.backgroundColor = .clear
        pageControl.currentPageIndicatorTintColor = .systemBlue
        pageControl.pageIndicatorTintColor = .systemGray3
        pageControl.currentPage = 0
        pageControl.numberOfPages = titles.count
        pageControl.addTarget(self, action: #selector(pageChanged), for: .valueChanged)
        return pageControl
    }()
    private var scrollWidth: CGFloat = 0.0
    private var scrollHeight: CGFloat = 0.0
    private var images = ["onboarding1", "onboarding2", "onboarding3"]
    private var titles = [Constants.Text.onboarding1, Constants.Text.onboardind2, Constants.Text.onboardind3]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupOnboardingView()
        setupScrollView()
    }
    
    override func viewDidLayoutSubviews() {
        scrollWidth = scrollView.frame.size.width
        scrollHeight = scrollView.frame.size.height
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        setIndicatorForCurrentPage()
    }
    
    private func setupOnboardingView() {
        var backImage = UIImage()
        if traitCollection.userInterfaceStyle == .dark {
            backImage = UIImage(named: "backgroundDark") ?? UIImage()
        } else {
            backImage = UIImage(named: "background") ?? UIImage()
        }
        view.backgroundColor = UIColor(patternImage: backImage)
        view.addSubview(scrollView)
        view.addSubview(pageControl)
        view.layoutIfNeeded()
    }
    
    private func setupScrollView() {
        self.scrollView.delegate = self
        setupSlide()
        scrollView.contentSize = CGSize(width: scrollWidth * CGFloat(titles.count),
                                        height: scrollHeight)
        scrollView.contentSize.height = 1.0
    }
    
    private func setupSlide() {
        var frame = CGRect(x: 0,
                           y: 0,
                           width: 0,
                           height: 0)
        for index in 0 ..< titles.count {
            frame.origin.x = scrollWidth * CGFloat(index)
            frame.size = CGSize(width: scrollWidth,
                                height: scrollHeight)
            let slide = UIView(frame: frame)
            let imageView = UIImageView(image: UIImage(named: images[index]))
            imageView.frame = CGRect(x: 0,
                                     y: 0,
                                     width: 150,
                                     height: 150)
            imageView.contentMode = .scaleAspectFit
            imageView.center = CGPoint(x: scrollWidth / 2,
                                       y: scrollHeight / 2 - 150)
            let text = UILabel(frame: CGRect(x: 32,
                                                  y: imageView.frame.maxY + 30,
                                                  width: scrollWidth - 64,
                                                  height: 50))
            text.textAlignment = .center
            text.font = UIFont.boldSystemFont(ofSize: 18.0)
            text.numberOfLines = 0
            text.text = titles[index]
            slide.addSubview(imageView)
            slide.addSubview(text)
            scrollView.addSubview(slide)
        }
    }
    
    private func setIndicatorForCurrentPage() {
        let page = scrollView.contentOffset.x / scrollWidth
        pageControl.currentPage = Int(page)
        if pageControl.currentPage == 2 {
            view.addSubview(nextButton)
        }
    }
    
    @objc private func tapNextButton() {
        self.navigationController?.pushViewController(LoginViewController(), animated: true)
    }
    
    @objc private func pageChanged(_ sender: Any) {
        scrollView.scrollRectToVisible(CGRect(x: scrollWidth * CGFloat((pageControl.currentPage)),
                                              y: 0,
                                              width: scrollWidth,
                                              height: scrollHeight),
                                       animated: true)
        if pageControl.currentPage == 2 {
            view.addSubview(nextButton)
        }
    }
}
