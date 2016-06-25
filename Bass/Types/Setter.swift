//  Copyright © 2016 Yoshiki Kudo. All rights reserved.

// MARK: - SetterType

public protocol SetterType: OpticType {
	var run: ((Target) -> Identity<AltTarget>) -> (Source) -> Identity<AltSource> { get }
}

public extension SetterType {
	public func over(_ f: (Target) -> AltTarget) -> (Source) -> AltSource {
		return { source in
			self.run{ .pure(f($0)) }(source).value
		}
	}
	
	public func set(_ x: AltTarget) -> (Source) -> AltSource {
		return { source in
			self.run{ _ in .pure(x) }(source).value
		}
	}
}

// MARK: - Setter

public struct Setter<S, T, A, B> {
	public let run: ((A) -> Identity<B>) -> (S) -> Identity<T>
	
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
}
