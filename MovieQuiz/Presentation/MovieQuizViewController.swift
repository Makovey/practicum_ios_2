import UIKit

protocol IMovieQuizViewController: AnyObject {
    func show(viewModel: QuizStepViewModel)
    func highlightImageBorder(isCorrectAnswer: Bool)
    func eraseImageBorder()
    func showGameResult(with model: QuizResultsViewModel)
    func showNetworkError(with message: String)
    func showLoading()
    func hideLoading()
    func enableButtons()
    func disableButtons()
}

final class MovieQuizViewController: UIViewController, IMovieQuizViewController {
    private struct Constants {
        static let borderWidth: CGFloat = 8
        static let borderRadius: CGFloat = 20
    }
    
    // MARK: - Properties
    private lazy var presenter: IMovieQuizPresenter = MoviesQuizPresenter(viewController: self)
    private lazy var alertPresenter: IAlertPresenter = AlertPresenter(controller: self)
    
    // MARK: - UI
    @IBOutlet private weak var questionTitleLabel: UILabel!
    @IBOutlet private weak var questionLabel: UILabel!
    @IBOutlet private weak var posterImageView: UIImageView!
    @IBOutlet private weak var counterLabel: UILabel!
    @IBOutlet private weak var noButton: UIButton!
    @IBOutlet private weak var yesButton: UIButton!
    @IBOutlet private weak var activityIndicator: UIActivityIndicatorView!
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUI()
        setupInitialState()
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        .lightContent
    }
    
    // MARK: - Methods    
    func show(viewModel: QuizStepViewModel) {
        posterImageView.image = viewModel.image
        questionLabel.text = viewModel.question
        counterLabel.text = viewModel.questionNumber
    }
    
    func showLoading() {
        activityIndicator.showLoadingIndicator()
    }
    
    func hideLoading() {
        activityIndicator.hideLoadingIndicator()
    }
    
    func enableButtons() {
        noButton.isEnabled = true
        yesButton.isEnabled = true
    }
    
    func disableButtons() {
        noButton.isEnabled = false
        yesButton.isEnabled = false
    }
    
    func highlightImageBorder(isCorrectAnswer: Bool) {
        let borderColor = isCorrectAnswer ? UIColor.ypGreen.cgColor : UIColor.ypRed.cgColor

        posterImageView.layer.borderWidth = Constants.borderWidth
        posterImageView.layer.borderColor = borderColor
    }
    
    func eraseImageBorder() {
        posterImageView.layer.borderWidth = .zero
    }
    
    func showGameResult(with alertViewModel: QuizResultsViewModel) {
        let alertModel = AlertModel(
            title: alertViewModel.title,
            message: alertViewModel.text,
            buttonText: alertViewModel.buttonText
        ) { [weak self] in
            guard let self else { return }
            self.presenter.restartGame()
        }
            
        alertPresenter.showResult(model: alertModel)
    }
    
    func showNetworkError(with message: String) {
        let alertModel = AlertModel(
            title: "alert_title_error".localized,
            message: message,
            buttonText: "alert_button_error_text".localized
        ) { [weak self] in
            guard let self else { return }
            self.presenter.loadDataIfNeeded()
            self.presenter.restartGame()
        }
        
        alertPresenter.showResult(model: alertModel)
    }
    
    // MARK: - Private
    private func setupUI() {
        posterImageView.layer.masksToBounds = true
        posterImageView.layer.cornerRadius = Constants.borderRadius
        
        questionTitleLabel.text = "common_question_text".localized
        noButton.setTitle("no_button_text".localized, for: .normal)
        yesButton.setTitle("yes_button_text".localized, for: .normal)
        
    }
    
    private func setupInitialState() {
        presenter.loadDataIfNeeded()
    }
    
    // MARK: - Actions
    @IBAction private func noButtonTapped() {
        presenter.noButtonTapped()
    }
    
    @IBAction private func yesButtonTapped() {
        presenter.yesButtonTapped()
    }
}
