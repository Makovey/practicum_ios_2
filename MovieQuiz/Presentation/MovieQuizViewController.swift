import UIKit

private extension CGFloat {
    static let borderWidth: CGFloat = 8
    static let borderRadius: CGFloat = 20
}

private extension Double {
    static let delay = 1.0
}

final class MovieQuizViewController: UIViewController {
    // MARK: - Properties
    private var questionFactory: IQuestionFactory?
    private var currentQuestion: QuizQuestionModel?

    private var currentQuestionIndex: Int = .zero
    private var correctAnswers: Int = .zero
    private let basicSizeOfQuestions = 10
    
    // MARK: - UI
    @IBOutlet private weak var questionLabel: UILabel!
    @IBOutlet private weak var posterImageView: UIImageView!
    @IBOutlet private weak var counterLabel: UILabel!
    @IBOutlet private var buttons: [UIButton]!
    
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
    private func setupInitialState() {
        questionFactory = QuestionFactory(delegate: self)
        questionFactory?.fetchNextQuestion()
    }
    
    private func setupUI() {
        posterImageView.layer.masksToBounds = true
        posterImageView.layer.cornerRadius = .borderRadius
    }
    
    private func show(viewModel: QuizStepViewModel) {
        posterImageView.image = viewModel.image
        questionLabel.text = viewModel.question
        counterLabel.text = viewModel.questionNumber
    }
    
    private func showNextQuestionOrResult() {
        buttons.forEach { $0.isEnabled = true }
        posterImageView.layer.borderWidth = .zero
        
        currentQuestionIndex += 1
        questionFactory?.fetchNextQuestion()
    }
    
    private func showAnswerResult(isCorrect: Bool) {
        buttons.forEach { $0.isEnabled = false }
        
        if isCorrect {
            correctAnswers += 1
        }
        
        let borderColor = isCorrect ? UIColor.ypGreen.cgColor : UIColor.ypRed.cgColor
        addBorder(with: borderColor)
        
        
        DispatchQueue.main.asyncAfter(deadline: .now() + .delay) { [weak self] in
            self?.showNextQuestionOrResult()
        }
    }
    
    private func convert(model: QuizQuestionModel) -> QuizStepViewModel {
        .init(
            image: .init(named: model.image) ?? UIImage(),
            question: model.text,
            questionNumber: "\(currentQuestionIndex + 1)/\(questionFactory?.quantity ?? basicSizeOfQuestions)"
        )
    }
    
    private func addBorder(with color: CGColor) {
        posterImageView.layer.borderWidth = .borderWidth
        posterImageView.layer.borderColor = color
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
            let alertViewModel = QuizResultsViewModel(
                title: "alert_title".localized,
                text: "\("alert_message".localized) \(correctAnswers)/\(questionFactory?.quantity ?? basicSizeOfQuestions)",
                buttonText: "alert_button_text".localized
            )
                        
            let alert = UIAlertController(
                title: alertViewModel.title,
                message: alertViewModel.text,
                preferredStyle: .alert
            )
            
            let action = UIAlertAction(title: alertViewModel.buttonText, style: .default) { [weak self] _ in
                guard let self else { return }
                self.currentQuestionIndex = .zero
                self.correctAnswers = .zero
                
                self.questionFactory?.fetchNextQuestion()
            }
            
            alert.addAction(action)
            self.present(alert, animated: true, completion: nil)
            
            return
        }
        currentQuestion = question
        let viewModel = convert(model: question)
        
        DispatchQueue.main.async { [weak self] in
            self?.show(viewModel: viewModel)
        }
    }
}
