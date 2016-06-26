//  Copyright © 2016 Yoshiki Kudo. All rights reserved.

// MARK: - PrismType

public protocol PrismType: OpticType {
	func forward (_ x: Source) -> Target?
	func backward (_ x: AltTarget) -> AltSource
}

// MARK: - Prism

public struct Prism<S, T, A, B> {
	private let _forward: (S) -> A?
	private let _backward: (B) -> T
}

// MARK: - Prism: PrismType

extension Prism: PrismType {
	public typealias Source = S
	public typealias Target = A
	public typealias AltSource = T
	public typealias AltTarget = B
	
	public func forward(_ x: S) -> A? {
		return _forward(x)
	}
	
	public func backward(_ x: B) -> T {
		return _backward(x)
	}
}
