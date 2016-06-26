//  Copyright © 2016 Yoshiki Kudo. All rights reserved.

// MARK: - SetterType

public protocol SetterType: OpticType {
	func over(_ f: (Target) -> Identity<AltTarget>) -> (Source) -> Identity<AltSource>
}

public extension SetterType {
	public func set(_ x: AltTarget) -> (Source) -> AltSource {
		return { source in
			self.over{ _ in .pure(x) }(source).value
		}
	}
}

// MARK: - Setter

public struct Setter<S, T, A, B> {
	private let run: ((A) -> Identity<B>) -> (S) -> Identity<T>
	
	public init(_ run: ((A) -> Identity<B>) -> (S) -> Identity<T>) {
		self.run = run
	}
}

// MARK: - Setter: SetterType

extension Setter: SetterType {
	public typealias Source = S
	public typealias Target = A
	public typealias AltSource = T
	public typealias AltTarget = B
	
	public func over(_ f: (A) -> Identity<B>) -> (S) -> Identity<T> {
		return run(f)
	}
}
