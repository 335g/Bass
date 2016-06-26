//  Copyright © 2016 Yoshiki Kudo. All rights reserved.

// MARK: - PrismType

public protocol PrismType: OpticType {
	func forward (_ x: Source) -> Target?
	func backward (_ x: AltTarget) -> AltSource
}

extension PrismType {
	public func compose <P: PrismType where Target == P.Source, AltTarget == P.AltSource> (_ other: P) -> Prism<Source, AltSource, P.Target, P.AltTarget> {
		
		return Prism(
			forward: { self.forward($0).flatMap(other.forward) },
			backward: self.backward • other.backward
		)
	}
}

public func >>> <L: PrismType, R: PrismType where L.Target == R.Source, L.AltTarget == R.AltSource>(lhs: L, rhs: R) -> Prism<L.Source, L.AltSource, R.Target, R.AltTarget> {
	
	return lhs.compose(rhs)
}

// MARK: - Prism

public struct Prism<S, T, A, B> {
	private let _forward: (S) -> A?
	private let _backward: (B) -> T
	
	public init(forward: (S) -> A?, backward: (B) -> T) {
		_forward = forward
		_backward = backward
	}
}

// MARK: - Prism: PrismType

extension Prism: PrismType {
	public typealias Source = S
	public typealias AltSource = T
	public typealias Target = A
	public typealias AltTarget = B
	
	public func forward(_ x: S) -> A? {
		return _forward(x)
	}
	
	public func backward(_ x: B) -> T {
		return _backward(x)
	}
}

// MARK: - SimplePrism

public struct SimplePrism<S, A> {
	private let _forward: (S) -> A?
	private let _backward: (A) -> S
	
	public init(forward: (S) -> A?, backward: (A) -> S){
		_forward = forward
		_backward = backward
	}
}

// MARK: - SimplePrism: PrismType

extension SimplePrism: PrismType {
	public typealias Source = S
	public typealias AltSource = S
	public typealias Target = A
	public typealias AltTarget = A
	
	public func forward(_ x: S) -> A? {
		return _forward(x)
	}
	
	public func backward(_ x: A) -> S {
		return _backward(x)
	}
}
