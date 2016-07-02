//  Copyright © 2016 Yoshiki Kudo. All rights reserved.

// MARK: - ConstType

public protocol ConstType: Foldable {
	associatedtype Value
	associatedtype Other
	
	var value: Value { get }
}

public extension ConstType {
	public func map<T>(_ f: (Other) -> T) -> Const<Value, T> {
		return Const(value)
	}
}

// MARK: - ConstType: Foldable

public extension ConstType {
	public func foldMap<M : Monoid>(f: (Other) -> M) -> M {
		return .mempty
	}
}

// MARK: - Const

public struct Const<A, B> {
	public let value: A
	
	public init(_ value: A){
		self.value = value
	}
}

// MARK: Const: ConstType

extension Const: ConstType {
	public typealias Value = A
	public typealias Other = B
}
