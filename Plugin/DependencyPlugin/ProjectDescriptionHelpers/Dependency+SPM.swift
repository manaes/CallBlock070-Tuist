import ProjectDescription

public extension TargetDependency {
    struct SPM {}
}

public extension TargetDependency.SPM {
    static let RxCocoa = TargetDependency.external(name: "RxCocoa")
    static let RxSwift = TargetDependency.external(name: "RxSwift")
    static let SnapKit = TargetDependency.external(name: "SnapKit")
}

public extension Package {
}
