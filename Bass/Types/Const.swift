//  Copyright © 2016 Yoshiki Kudo. All rights reserved.

// MARK: - ConstType

public protocol ConstType: IdentityType {
	associatedtype Other
}

public extension ConstType {
	public func map<T, C: ConstType where Other == Target, C.Value == Value, C.Other == T, C.Target == T>(_ f: (Target) -> T) -> C {
		return C(value)
	}
}

// MARK: - ConstType: Foldable

public extension ConstType {
	public func foldMap<M : Monoid>(f: (Other) -> M) -> M {
		return .mempty
	}
	
	public func null() -> Bool {
		return true
	}
	
	public func length() -> Int {
		return 0
	}
	
	public func find(predicate: (Value) -> Bool) throws -> Value? {
		return nil
	}
	
	public func toList() -> [Value] {
		return []
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
	public typealias Target = B
}
