import UIKit

protocol IMovieQuizViewController {
    func showAnswerResult(isCorrect: Bool)
    func show(viewModel: QuizStepViewModel)
    func showLoading()
}

final class MovieQuizViewController: UIViewController {
    private struct Constants {
        static let borderWidth: CGFloat = 8
        static let borderRadius: CGFloat = 20
        static let delay = 1.5
    }
    
    // MARK: - Properties
    private lazy var questionFactory: IQuestionFactory = QuestionFactory(moviesLoader: moviesLoader, delegate: self)
    private lazy var presenter: IMovieQuizPresenter = MoviesQuizPresenter(questionFactory: questionFactory)
    private let moviesLoader: IMoviesLoader = MoviesLoader()
    
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
    func showAnswerResult(isCorrect: Bool) {
        noButton.isEnabled = false
        yesButton.isEnabled = false
        
        if isCorrect {
            presenter.updateCorrectAnswers()
        }
        
        let borderColor = isCorrect ? UIColor.ypGreen.cgColor : UIColor.ypRed.cgColor
        addBorder(with: borderColor)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + Constants.delay) { [weak self] in
            guard let self else { return }
            self.noButton.isEnabled = true
            self.yesButton.isEnabled = true
            self.posterImageView.layer.borderWidth = .zero
            self.presenter.showNextQuestionOrResult()
        }
    }
    
    func show(viewModel: QuizStepViewModel) {
        posterImageView.image = viewModel.image
        questionLabel.text = viewModel.question
        counterLabel.text = viewModel.questionNumber
    }
    
    func showLoading() {
        activityIndicator.showLoadingIndicator()
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
        presenter.viewController = self
        activityIndicator.showLoadingIndicator()
        questionFactory.loadDataIfNeeded()
    }
    
    private func addBorder(with color: CGColor) {
        posterImageView.layer.borderWidth = Constants.borderWidth
        posterImageView.layer.borderColor = color
    }
    
    // MARK: - Actions
    @IBAction private func noButtonTapped() {
        presenter.noButtonTapped()
    }
    
    @IBAction private func yesButtonTapped() {
        presenter.yesButtonTapped()
    }
}

// MARK: - IQuestionFactoryDelegate
extension MovieQuizViewController: IQuestionFactoryDelegate {
    func didReceiveNextQuestion(question: QuizQuestionModel?) {
        presenter.didReceiveNextQuestion(question: question)
    }
    
    func didLoadDataFromServer() {
        activityIndicator.hideLoadingIndicator()
        questionFactory.fetchNextQuestion()
    }
    
    func didFailToLoadDataFromServer(with error: NetworkError) {
        activityIndicator.hideLoadingIndicator()
        presenter.showNetworkError(message: error.titleMessage)
    }
}
