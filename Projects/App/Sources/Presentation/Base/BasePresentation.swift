//
//  BasePresentation.swift
//  Block070
//
//  Created by 박주완 on 12/14/24.
//

import RxSwift
import UIKit

protocol BaseViewProtocol where Self: UIViewController {
    /// Layout View
    /// 코드로 작성한 뷰 관리
    func layoutView()

    /// Bind ViewModel
    /// viewModel Bind
    func bindViewModel()

    /// InitView
    /// 화면내 필요한 UI 정의
    func initView()

    /// RxSetup
    /// RxValue 등을 처리
    func rxSetup()
}

protocol ViewModelType {
    /// ViewModel In/Out
    associatedtype Input
    associatedtype Output

    /// Disposebag
    var disposeBag: DisposeBag { get set }

    /// Bind In/Out
    func transform(input: Input) -> Output
}
