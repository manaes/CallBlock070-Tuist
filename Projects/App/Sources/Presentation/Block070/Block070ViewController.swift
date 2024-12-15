//
//  Block070ViewController.swift
//  Block070
//
//  Created by 박주완 on 12/14/24.
//

import RxCocoa
import RxSwift
import SnapKit
import UIKit

final class Block070ViewController: UIViewController {
    /// Start Button
    ///
    /// 차단동작 실행 버튼
    ///
    lazy var startBtn: UIButton = {
        let button = UIButton(frame: .zero)
        button.setTitle("070 전체 차단하기", for: .normal)
        button.setTitleColor(.systemBlue, for: .normal)
        return button
    }()

    /// LoadingView
    ///
    /// 진행중일때,Indicator + 진행상태 (percent)
    ///
    lazy var loadingView: UIView = {
        let view = UIView(frame: .zero)
        view.isHidden = true
        return view
    }()

    lazy var indicator: UIActivityIndicatorView = {
        let view = UIActivityIndicatorView(frame: .zero)
        view.hidesWhenStopped = true
        view.style = .large
        return view
    }()

    lazy var processView: UIProgressView = {
        let view = UIProgressView(frame: .zero)
        view.trackTintColor = .lightGray
        view.progressTintColor = .systemBlue
        return view
    }()

    lazy var processLabel: UILabel = {
        let label = UILabel(frame: .zero)
        label.font = .systemFont(ofSize: 11)
        label.textAlignment = .center
        return label
    }()

    lazy var remainingTimeLabel: UILabel = {
        let label = UILabel(frame: .zero)
        label.font = .systemFont(ofSize: 11)
        label.textAlignment = .center
        return label
    }()

    /// ViewModel
    private lazy var input = Block070ViewModel.Input(
        startEvent: startBtn.rx.tap.asSignal()
    )
    private lazy var output = viewModel.transform(input: input)
    private var viewModel: Block070ViewModel

    /// RxSwift
    private let disposeBag = DisposeBag()

    // MARK: - Class Cycle

    init(viewModel: Block070ViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }

    @available(*, unavailable)
    required init?(coder _: NSCoder) {
        fatalError("required init error!!")
    }

    // MARK: - View Cycle

    override func viewDidLoad() {
        super.viewDidLoad()

        layoutView()
        bindViewModel()
        initView()
        rxSetup()
    }
}

extension Block070ViewController: BaseViewProtocol {
    // MARK: - Layout View

    func layoutView() {
        /// Button
        ///
        view.addSubview(startBtn)

        startBtn.snp.makeConstraints { make in
            make.center.equalToSuperview()
        }

        /// Loading View
        ///
        view.addSubview(loadingView)

        loadingView.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(20)
            make.trailing.equalToSuperview().offset(-20)
            make.centerY.equalToSuperview()
        }

        let stackView = UIStackView(frame: .zero)
        stackView.addArrangedSubview(indicator)
        stackView.addArrangedSubview(processView)
        stackView.addArrangedSubview(processLabel)
        stackView.addArrangedSubview(remainingTimeLabel)
        stackView.spacing = 20
        stackView.axis = .vertical

        loadingView.addSubview(stackView)

        stackView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }

    // MARK: - Bind ViewModel

    func bindViewModel() {
        output.isSaving.asObservable()
            .observe(on: MainScheduler.instance)
            .subscribe(with: self, onNext: { owner, isSaving in
                /// 진행중 시작버튼 숨기기
                owner.startBtn.isHidden = isSaving

                /// 로딩화면 전환
                owner.loadingView.isHidden = !isSaving
                owner.indicator.startAnimating()

                /// 화면 자동 꺼짐 방지
                UIApplication.shared.isIdleTimerDisabled = isSaving
            })
            .disposed(by: disposeBag)

        output.processEvent.asObservable()
            .observe(on: MainScheduler.instance)
            .subscribe(with: self, onNext: { owner, process in
                owner.processView.setProgress(Float(process) / 100, animated: true)
                owner.processLabel.text = "진행 중 (\(process)%)"
            })
            .disposed(by: disposeBag)

        output.remainingTimeEvent.asObservable()
            .map { seconds -> String in
                let minutes = seconds / 60
                let remainingSeconds = seconds % 60
                return String(format: "%02d:%02d", minutes, remainingSeconds)
            }
            .observe(on: MainScheduler.instance)
            .subscribe(with: self, onNext: { owner, time in
                owner.remainingTimeLabel.text = "앱을 종료하지마세요. 약 \(time) 후 완료 예상"
            })
            .disposed(by: disposeBag)

        output.errorEvent.asObservable()
            .observe(on: MainScheduler.instance)
            .subscribe(with: self, onNext: { owner, error in
                owner.loadingView.isHidden = true
                owner.startBtn.isHidden = false

                /// Show Error Alert
                var message: String {
                    switch error {
                    case let .disabled(index):
                        "전화 - 차단 및 발신자 확인에서 CallBlocker\(String(format: "%02d", index))를 활성화해주세요."
                    default:
                        "\(error)"
                    }
                }
                let alertController = UIAlertController(title: "에러", message: message, preferredStyle: .alert)
                alertController.addAction(UIAlertAction(title: "확인", style: .default))
                owner.present(alertController, animated: true)
            })
            .disposed(by: disposeBag)
    }

    // MARK: - Init View

    func initView() {}

    // MARK: - RxSetup

    func rxSetup() {}
}
