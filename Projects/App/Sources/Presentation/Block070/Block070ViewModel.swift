//
//  Block070ViewModel.swift
//  Block070
//
//  Created by 박주완 on 12/14/24.
//

import CallKit
import Config
import Foundation
import Log
import RxCocoa
import RxSwift

enum Block070Error {
    case disabled(Int)
    case custom(Error)
}

final class Block070ViewModel: ViewModelType {
    struct Input {
        let startEvent: Signal<Void>
    }

    struct Output {
        let isSaving: Signal<Bool>
        let processEvent: Signal<Float>
        let remainingTimeEvent: Signal<Int>
        let errorEvent: Signal<Block070Error>
    }

    var disposeBag = DisposeBag()

    private let isSaving = PublishRelay<Bool>()
    private let processEvent = PublishRelay<Float>()
    private let remainingTimeEvent = PublishRelay<Int>()
    private let errorEvent = PublishRelay<Block070Error>()

    // MARK: - In / Out

    func transform(input: Input) -> Output {
        /// isSaving시, App Group에 저장 가능 상태 업데이트
        /// 설정에서 switch on과 앱 업데이트 기능을 분리하기 위함
        isSaving.asObservable()
            .distinctUntilChanged()
            .subscribe(onNext: {
                AppConfig.isBlock = $0
            })
            .disposed(by: disposeBag)

        Task { [weak self] in
            for try await _ in input.startEvent.asObservable().values {
                guard let self else { continue }

                let startTime = Date()
                Log.debug("start block")

                /// Start
                isSaving.accept(true)

                /// Check Enable / Save Block
                for idx in 1 ... CallBlockerConfig.maxBlockManager {
                    let identifier = CallBlockerConfig.identifierPrefix + String(format: "%02d", idx)
                    do {
                        try await block070(at: idx, withIdentifier: identifier)
                    } catch {
                        Log.error("Error occurred for \(identifier): \(error)")
                        errorEvent.accept(.custom(error))
                    }
                }

                /// End
                isSaving.accept(false)

                let endTime = abs(startTime.timeIntervalSinceNow)
                Log.debug("end block \(endTime)")
            }
        }

        return Output(
            isSaving: isSaving.asSignal(),
            processEvent: processEvent.asSignal(),
            remainingTimeEvent: remainingTimeEvent.asSignal(),
            errorEvent: errorEvent.asSignal()
        )
    }
}

// MARK: - Block 070

extension Block070ViewModel {
    private func block070(at idx: Int, withIdentifier identifier: String) async throws {
        /// 동작시간을 확인하기 위한 변수
        let startTime = Date()

        Log.debug("check enabled")

        // Check enabled status
        // swiftlint:disable:next line_length
        let status = try await CXCallDirectoryManager.sharedInstance.enabledStatusForExtension(withIdentifier: identifier)
        guard status == .enabled else {
            Log.debug("\(identifier) is disabled or error occurred.")
            errorEvent.accept(Block070Error.disabled(idx))
            return
        }

        Log.debug("Enabled \(identifier)")

        /// Reload extension
        try await CXCallDirectoryManager.sharedInstance.reloadExtension(withIdentifier: identifier)

        /// Process
        let process = Float(idx * 100) / Float(CallBlockerConfig.maxBlockManager)
        processEvent.accept(process)

        /// Calculate remaining time
        let elapsedTime = abs(startTime.timeIntervalSinceNow)
        let remainingTime = Int(elapsedTime * Double(CallBlockerConfig.maxBlockManager - idx))
        remainingTimeEvent.accept(remainingTime)

        Log.debug("Updated Complete \(idx) -> \(identifier) : \(elapsedTime)")
    }
}
