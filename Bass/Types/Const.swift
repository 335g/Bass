//  Copyright © 2016 Yoshiki Kudo. All rights reserved.

// MARK: - ConstType

public protocol ConstType: IdentityType {
	associatedtype Other
}

public extension ConstType {
	public func cast<C: ConstType where C.Value == Value>(type: C.Other.Type) -> C {
		return C(value)
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
