//
//  AppConfig.swift
//  AppConfig
//
//  Created by 박주완 on 12/12/24.
//  Copyright © 2024 kr.co.wannypark. All rights reserved.
//

import Foundation

public enum AppConfig {
    private static let groupIdentifier = "group.co.kr.wannypark"

    /// Group Key
    private static let isBlockUpdate = "IS_BLOCK_UPDATE"

    /// 앱 - 차단 실행과 설정 - 차단 on/off를 구분하기 위한 변수
    public static var isBlock: Bool {
        get {
            let group = UserDefaults(suiteName: groupIdentifier)!
            return group.bool(forKey: isBlockUpdate)
        }
        set {
            let group = UserDefaults(suiteName: groupIdentifier)!
            group.set(newValue, forKey: isBlockUpdate)
        }
    }
}
