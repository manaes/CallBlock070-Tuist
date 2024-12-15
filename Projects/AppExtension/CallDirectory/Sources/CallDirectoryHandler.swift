//
//  CallDirectoryHandler.swift
//  070Blocker_01
//
//  Created by 박주완 on 11/27/24.
//

import CallKit
import Config
import Foundation
import Log

class CallDirectoryHandler: CXCallDirectoryProvider {
    // MARK: - Start Block 070

    override func beginRequest(with context: CXCallDirectoryExtensionContext) {
        context.delegate = self

        if context.isIncremental {
            context.removeAllBlockingEntries()
        }

        /// 앱에서 차단하기 동작을 실행할때만, 070번호차단을 시작함
        if AppConfig.isBlock {
            addBlock070(with: context)
        }
        context.completeRequest()
    }
}

// MARK: - Error

extension CallDirectoryHandler: CXCallDirectoryExtensionContextDelegate {
    func requestFailed(for _: CXCallDirectoryExtensionContext, withError error: Error) {
        Log.error("RequestFailed \(error)")
    }
}

// MARK: - Add Block

extension CallDirectoryHandler {
    public func addBlock070(with context: CXCallDirectoryExtensionContext) {
        // swiftlint:disable:next line_length
        guard let indexString = Bundle.main.bundleIdentifier?.replacingOccurrences(of: CallBlockerConfig.identifierPrefix, with: ""),
              let index = Int(indexString)
        else {
            return
        }

        for number in 1 ..< CallBlockerConfig.maxBlockNumCount {
            autoreleasepool {
                /// 1 ~ 2_000_000
                /// (1 ~ 2_000_000) + 1 * 2_000_0000
                /// (1 ~ 2_000_000) + 2 * 2_0000_000
                /// ...
                ///
                // swiftlint:disable:next line_length
                let numberString = "+8270" + String(format: "%08d", number + ((index - 1) * CallBlockerConfig.maxBlockNumCount))

                /// 특정패턴 번호 제외
                /// 000 포함하는 경우
                if numberString.contains("000") { return }

                guard let relatedNumber = CXCallDirectoryPhoneNumber(numberString) else { return }
                context.addBlockingEntry(withNextSequentialPhoneNumber: relatedNumber)
            }
        }
    }
}
