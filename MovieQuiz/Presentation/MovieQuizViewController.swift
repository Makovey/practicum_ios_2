import UIKit

final class MovieQuizViewController: UIViewController {
    private struct Constants {
        static let borderWidth: CGFloat = 8
        static let borderRadius: CGFloat = 20
        static let delay = 1.5
    }
    
    // MARK: - Properties
    private lazy var questionFactory: IQuestionFactory = QuestionFactory(moviesLoader: moviesLoader, delegate: self)
    private lazy var alertPresenter: IAlertPresenter = AlertPresenter(controller: self)
    private let statisticService: IStatisticService = StatisticService()
    private let moviesLoader: IMoviesLoader = MoviesLoader()
    private var currentQuestion: QuizQuestionModel?

    private var currentQuestionIndex: Int = .zero
    private var correctAnswers: Int = .zero
    
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
    private func setupUI() {
        posterImageView.layer.masksToBounds = true
        posterImageView.layer.cornerRadius = Constants.borderRadius
        
        questionTitleLabel.text = "common_question_text".localized
        noButton.setTitle("no_button_text".localized, for: .normal)
        yesButton.setTitle("yes_button_text".localized, for: .normal)
        
    }
    
    private func setupInitialState() {
        activityIndicator.showLoadingIndicator()
        questionFactory.loadDataIfNeeded()
    }
    
    private func show(viewModel: QuizStepViewModel) {
        posterImageView.image = viewModel.image
        questionLabel.text = viewModel.question
        counterLabel.text = viewModel.questionNumber
    }
    
    private func showNextQuestionOrResult() {
        noButton.isEnabled = true
        yesButton.isEnabled = true
        posterImageView.layer.borderWidth = .zero
        
        currentQuestionIndex += 1
        questionFactory.fetchNextQuestion()
    }
    
    private func showAnswerResult(isCorrect: Bool) {
        noButton.isEnabled = false
        yesButton.isEnabled = false
        
        if isCorrect {
            correctAnswers += 1
        }
        
        let borderColor = isCorrect ? UIColor.ypGreen.cgColor : UIColor.ypRed.cgColor
        addBorder(with: borderColor)
        
        
        DispatchQueue.main.asyncAfter(deadline: .now() + Constants.delay) { [weak self] in
            self?.showNextQuestionOrResult()
        }
        //
    }
    
    private func convert(model: QuizQuestionModel) -> QuizStepViewModel {
        .init(
            image: UIImage(data: model.imageData) ?? UIImage(),
            question: model.text,
            questionNumber: "\(currentQuestionIndex + 1)/\(questionFactory.quantity)"
        )
    }
    
    private func addBorder(with color: CGColor) {
        posterImageView.layer.borderWidth = Constants.borderWidth
        posterImageView.layer.borderColor = color
    }
    
    private func showNetworkError(message: String) {
        let alertModel = AlertModel(
            title: "alert_title_error".localized,
            message: message,
            buttonText: "alert_button_error_text".localized) { [weak self] in
                guard let self else { return }
                
                self.currentQuestionIndex = .zero
                self.correctAnswers = .zero
                
                self.questionFactory.resetQuestions()
                self.questionFactory.loadDataIfNeeded()
            }
        
        alertPresenter.showResult(model: alertModel)
    }
    
    // MARK: - Actions
    @IBAction private func noButtonTapped() {
        guard let currentQuestion else { return }
        let usersAnswer = false
        showAnswerResult(isCorrect: usersAnswer == currentQuestion.correctAnswer)
    }
    
    @IBAction private func yesButtonTapped() {
        guard let currentQuestion else { return }
        let usersAnswer = true
        showAnswerResult(isCorrect: usersAnswer == currentQuestion.correctAnswer)
    }
}

// MARK: - IQuestionFactoryDelegate
extension MovieQuizViewController: IQuestionFactoryDelegate {
    func didReceiveNextQuestion(question: QuizQuestionModel?) {
        guard let question else {
            let currentResult = RecordModel(
                correctAnswers: correctAnswers,
                totalQuestions: questionFactory.quantity,
                date: Date()
            )
            
            statisticService.storeAttempt(newResult: currentResult)
            
            let alertViewModel = QuizResultsViewModel.makeViewModel(
                currentResult: currentResult,
                statisticService: statisticService
            )
            
            let alertModel = AlertModel(
                title: alertViewModel.title,
                message: alertViewModel.text,
                buttonText: alertViewModel.buttonText) { [weak self] in
                guard let self else { return }
                self.currentQuestionIndex = .zero
                self.correctAnswers = .zero
                self.questionFactory.resetQuestions()
                self.questionFactory.fetchNextQuestion()
            }
                        
            alertPresenter.showResult(model: alertModel)
            
            return
        }
        currentQuestion = question
        let viewModel = convert(model: question)
        
        DispatchQueue.main.async { [weak self] in
            self?.show(viewModel: viewModel)
        }
    }
    
    func didLoadDataFromServer() {
        activityIndicator.hideLoadingIndicator()
        questionFactory.fetchNextQuestion()
    }
    
    func didFailToLoadDataFromServer(with error: NetworkError) {
        activityIndicator.hideLoadingIndicator()
        showNetworkError(message: error.titleMessage)
    }
}
