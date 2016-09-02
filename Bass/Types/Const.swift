//  Copyright © 2016 Yoshiki Kudo. All rights reserved.

// MARK: - ConstType

public protocol ConstType: Foldable {
	associatedtype Value
	associatedtype Other
	
	var value: Value { get }
	init(_ value: Value)
}

public extension ConstType {
	public func map<T, C: ConstType>(_ f: (Other) -> T) -> C
		where C.Value == Value, C.Other == T {
			
			return C(value)
	}
}

// MARK: - ConstType: Foldable

public extension ConstType {
	public func foldMap<M : Monoid>(_ f: @escaping (Other) -> M) -> M {
		return .mempty
	}
	
	public func null() -> Bool {
		return true
	}
	
	public func length() -> Int {
		return 0
	}
	
	public func find(_ predicate: @escaping (Value) -> Bool) throws -> Value? {
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
}
