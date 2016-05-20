//  Copyright © 2016 Yoshiki Kudo. All rights reserved.

// MARK: - TheseType

public protocol TheseType {
	associatedtype ThisType
	associatedtype ThatType
	
	static func this(x: ThisType) -> Self
	static func that(x: ThatType) -> Self
	static func both(x: ThisType, y: ThatType) -> Self
	
	func these<T>(@noescape ifThis ifThis: ThisType throws -> T, ifThat: ThatType throws -> T, ifBoth: (ThisType, ThatType) throws -> T) rethrows -> T
}

// MARK: - TheseType - method

public extension TheseType {
	public var this: ThisType? {
		return these(
			ifThis: id,
			ifThat: const(nil),
			ifBoth: const(nil)
		)
	}
	
	public var that: ThatType? {
		return these(
			ifThis: const(nil),
			ifThat: id,
			ifBoth: const(nil)
		)
	}
	
	public var both: (ThisType, ThatType)? {
		return these(
			ifThis: const(nil),
			ifThat: const(nil),
			ifBoth: id
		)
	}
	
	public var isThis: Bool {
		return these(
			ifThis: const(true),
			ifThat: const(false),
			ifBoth: const(false)
		)
	}
	
	public var isThat: Bool {
		return these(
			ifThis: const(false),
			ifThat: const(true),
			ifBoth: const(false)
		)
	}
	
	public var isBoth: Bool {
		return these(
			ifThis: const(false),
			ifThat: const(false),
			ifBoth: const(true)
		)
	}
}

// MARK; - These

public enum These<A, B> {
	case This(A)
	case That(B)
	case Both(A, B)
}

// MARK: - These: TheseType

extension These: TheseType {
	public typealias ThisType = A
	public typealias ThatType = B
	
	public static func this(x: A) -> These {
		return .This(x)
	}
	
	public static func that(x: B) -> These {
		return .That(x)
	}
	
	public static func both(x: A, y: B) -> These {
		return .Both(x, y)
	}
	
	public func these<T>(@noescape ifThis ifThis: A throws -> T, ifThat: B throws -> T, ifBoth: (A, B) throws -> T) rethrows -> T {
		switch self {
		case .This(let a):
			return try ifThis(a)
		case .That(let b):
			return try ifThat(b)
		case .Both(let a, let b):
			return try ifBoth(a, b)
		}
	}
}