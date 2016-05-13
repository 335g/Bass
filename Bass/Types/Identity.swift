//  Copyright © 2016 Yoshiki Kudo. All rights reserved.

// MARK: - IdentityType

public protocol IdentityType: Foldable {
	associatedtype Value
	
	var value: Value { get }
	init(_ value: Value)
}

// MARK: - IdentityType: Foldable

public extension IdentityType {
	public func foldMap<M : Monoid>(f: Value -> M) -> M {
		return f(value)
	}
	
	public func foldr<T>(initial: T, _ f: Value -> T -> T) -> T {
		return f(value)(initial)
	}
	
	public func foldr1(f: Value -> Value -> Value) throws -> Value {
		return value
	}
	
	public func foldl<T>(initial: T, _ f: T -> Value -> T) -> T {
		return f(initial)(value)
	}
	
	public func foldl1(f: Value -> Value -> Value) throws -> Value {
		return value
	}
	
	public func null() -> Bool {
		return false
	}
	
	public func length() -> Int {
		return 1
	}
	
	public func find(predicate: Value -> Bool) throws -> Value? {
		guard predicate(value) else {
			return nil
		}
		
		return value
	}
	
	public func toList() -> [Value] {
		return [value]
	}
}

// MARK: - Identity

public final class Identity<T>: IdentityType {
	public let value: T
	
	public init(_ value: T) {
		self.value = value
	}
}
