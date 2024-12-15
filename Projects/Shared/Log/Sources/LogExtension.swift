//
//  LogExtension.swift
//  SplashFeatureInterface
//
//  Created by 박주완 on 12/7/24.
//  Copyright © 2022 co.kr.wannypark. All rights reserved.
//

import Foundation
import os.log

extension OSLog {
    static let subsystem = Bundle.main.bundleIdentifier ?? ""
    static let network = OSLog(subsystem: subsystem, category: "Network")
    static let debug = OSLog(subsystem: subsystem, category: "Debug")
    static let info = OSLog(subsystem: subsystem, category: "Info")
    static let error = OSLog(subsystem: subsystem, category: "Error")
    static let token = OSLog(subsystem: subsystem, category: "Token")
}

public class Log: NSObject {
    /**
     # (e) Level
     - Authors : wanny.park
     - debug : 디버깅 로그
     - info : 문제 해결 정보
     - network : 네트워크 정보
     - error :  오류
     - token: 토큰
     - custom(category: String) : 커스텀 디버깅 로그
     */
    public enum Level {
        /// 디버깅 로그
        case debug
        /// 문제 해결 정보
        case info
        /// 네트워크 로그
        case network
        /// 오류 로그
        case error
        /// 토큰 로그
        case token
        case custom(category: String)

        var category: String {
            switch self {
            case .debug:
                "🟡 DEBUG"
            case .info:
                "🟠 INFO"
            case .network:
                "🔵 NETWORK"
            case .error:
                "🔴 ERROR"
            case .token:
                "🟢 TOKEN"
            case let .custom(category):
                "🟢 \(category)"
            }
        }

        var osLog: OSLog {
            switch self {
            case .debug:
                OSLog.debug
            case .info:
                OSLog.info
            case .network:
                OSLog.network
            case .error:
                OSLog.error
            case .token:
                OSLog.token
            case .custom:
                OSLog.debug
            }
        }

        var osLogType: OSLogType {
            switch self {
            case .debug:
                .debug
            case .info:
                .info
            case .network:
                .default
            case .error:
                .error
            case .token:
                .default
            case .custom:
                .debug
            }
        }
    }

    public static func log(_ message: Any, level: Level) {
        #if DEBUG
            if #available(iOS 14.0, *) {
                let logger = Logger(subsystem: OSLog.subsystem, category: level.category)
                let logMessage = "\(message)"
                switch level {
                case .debug,
                     .custom:
                    logger.debug("\(logMessage, privacy: .public)")
                case .info:
                    logger.info("\(logMessage, privacy: .public)")
                case .network:
                    logger.log("\(logMessage, privacy: .public)")
                case .error:
                    logger.error("\(logMessage, privacy: .public)")
                case .token:
                    logger.error("\(logMessage, privacy: .public)")
                }
            } else {
                os_log("%{public}@", log: level.osLog, type: level.osLogType, "\(message)")
            }
        #endif
    }
}

// MARK: - utils

public extension Log {
    /**
     # debug
     - Note : 개발 중 코드 디버깅 시 사용할 수 있는 유용한 정보
     */
    static func debug(_ message: Any) {
        log(message, level: .debug)
    }

    /**
     # info
     - Note : 문제 해결시 활용할 수 있는, 도움이 되지만 필수적이지 않은 정보
     */
    static func info(_ message: Any) {
        log(message, level: .info)
    }

    /**
     # network
     - Note : 네트워크 문제 해결에 필수적인 정보
     */
    static func network(_ message: Any) {
        log(message, level: .network)
    }

    /**
     # token
     - Note : 트큰 로직 관련 로그
     */
    static func token(_ message: Any) {
        log(message, level: .token)
    }

    /**
     # error
     - Note : 코드 실행 중 나타난 에러
     */
    static func error(_ message: Any) {
        log(message, level: .error)
    }

    /**
     # custom
     - Note : 커스텀 디버깅 로그
     */
    static func custom(category: String, _ message: Any) {
        log(message, level: .custom(category: category))
    }
}
