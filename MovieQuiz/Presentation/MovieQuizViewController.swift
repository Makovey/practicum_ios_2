import UIKit

private extension String {
    static let commonQuestion = "common_question".localized
}

private extension CGFloat {
    static let borderWidth: CGFloat = 8
    static let borderRadius: CGFloat = 20
}

private extension Double {
    static let delay = 1.0
}

final class MovieQuizViewController: UIViewController {
    // MARK: - Properties
    private var questions: [QuizQuestionModel] = [
        .init(image: "Vivarium", text: .commonQuestion, correctAnswer: false),
        .init(image: "The Godfather", text: .commonQuestion, correctAnswer: true),
        .init(image: "Old", text: .commonQuestion, correctAnswer: false),
        .init(image: "The Dark Knight", text: .commonQuestion, correctAnswer: true),
        .init(image: "Kill Bill", text: .commonQuestion, correctAnswer: true),
        .init(image: "Tesla", text: .commonQuestion, correctAnswer: false),
        .init(image: "The Avengers", text: .commonQuestion, correctAnswer: true),
        .init(image: "Deadpool", text: .commonQuestion, correctAnswer: true),
        .init(image: "The Green Knight", text: .commonQuestion, correctAnswer: true),
        .init(image: "The Ice Age Adventures of Buck Wild", text: .commonQuestion, correctAnswer: false)
    ]
    
    private var currentQuestionIndex: Int = .zero
    private var correctAnswers: Int = .zero
    
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
    
    // MARK: - Functions
    private func setupInitialState() {
        questions = questions.shuffled()
        guard let firstQuestion = questions[safe: currentQuestionIndex] else { return }
        let viewModel = convert(model: firstQuestion)
        show(viewModel: viewModel)
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
        guard let nextQuestion = questions[safe: currentQuestionIndex] else {
            let alertViewModel = QuizResultsViewModel(
                title: "alert_title".localized,
                text: "\("alert_message".localized) \(correctAnswers)/\(questions.count)",
                buttonText: "alert_button_text".localized
            )
            
            return showResult(viewModel: alertViewModel)
        }
        let viewModel = convert(model: nextQuestion)
        show(viewModel: viewModel)
    }
    
    private func showAnswerResult(isCorrect: Bool) {
        buttons.forEach { $0.isEnabled = false }
        
        if isCorrect {
            correctAnswers += 1
        }
        
        let borderColor = isCorrect ? UIColor.ypGreen.cgColor : UIColor.ypRed.cgColor
        addBorder(with: borderColor)
        
        
        DispatchQueue.main.asyncAfter(deadline: .now() + .delay) {
            self.showNextQuestionOrResult()
        }
    }
    
    private func showResult(viewModel: QuizResultsViewModel) {
        let alert = UIAlertController(
            title: viewModel.title,
            message: viewModel.text,
            preferredStyle: .alert
        )
        
        let action = UIAlertAction(title: viewModel.buttonText, style: .default) { _ in
            self.questions = self.questions.shuffled()
            
            self.currentQuestionIndex = .zero
            self.correctAnswers = .zero
            
            guard let firstQuestion = self.questions[safe: self.currentQuestionIndex] else { return }
            let viewModel = self.convert(model: firstQuestion)
            self.show(viewModel: viewModel)
        }
        
        alert.addAction(action)
        self.present(alert, animated: true, completion: nil)
    }
    
    private func convert(model: QuizQuestionModel) -> QuizStepViewModel {
        .init(
            image: .init(named: model.image) ?? UIImage(),
            question: model.text,
            questionNumber: "\(currentQuestionIndex + 1)/\(questions.count)"
        )
    }
    
    private func addBorder(with color: CGColor) {
        posterImageView.layer.borderWidth = .borderWidth
        posterImageView.layer.borderColor = color
    }
    
    // MARK: - Actions
    @IBAction private func noButtonTapped() {
        guard let currentQuestion = questions[safe: currentQuestionIndex] else { return }
        let usersAnswer = false
        showAnswerResult(isCorrect: usersAnswer == currentQuestion.correctAnswer)
    }
    
    @IBAction private func yesButtonTapped() {
        guard let currentQuestion = questions[safe: currentQuestionIndex] else { return }
        let usersAnswer = true
        showAnswerResult(isCorrect: usersAnswer == currentQuestion.correctAnswer)
    }
}

// MARK: - Private Models
private struct QuizQuestionModel {
    let image: String
    let text: String
    let correctAnswer: Bool
}

private struct QuizStepViewModel {
    let image: UIImage
    let question: String
    let questionNumber: String
}

private struct QuizResultsViewModel {
    let title: String
    let text: String
    let buttonText: String
}
