//  Copyright © 2016 Yoshiki Kudo. All rights reserved.

// MARK: - TheseType

public protocol TheseType: Pointed, Foldable {
	associatedtype ThisType
	associatedtype ThatType
	
	init(this: ThisType)
	init(that: ThatType)
	init(this: ThisType, that: ThatType)
	
	func these<T>(ifThis: @noescape (ThisType) throws -> T, ifThat: @noescape (ThatType) throws -> T, ifBoth: @noescape (ThisType, ThatType) throws -> T) rethrows -> T
}

// MARK: - TheseType: Pointed

public extension TheseType {
	public static func pure(_ x: ThatType) -> Self {
		return Self(that: x)
	}
}

// MARK: - TheseType: Foldable

public extension TheseType {
	public func foldMap<M : Monoid>(_ f: (ThatType) -> M) -> M {
		return these(
			ifThis: const(.mempty),
			ifThat: { f($0) },
			ifBoth: { f($1) }
		)
	}
	
	public func foldr<T>(initial: T, _ f: (ThatType) -> (T) -> T) -> T {
		return these(
			ifThis: const(initial),
			ifThat: { f($0)(initial) },
			ifBoth: { f($1)(initial) }
		)
	}
	
	public func null() -> Bool {
		return isThis
	}
	
	public func length() -> Int {
		return these(
			ifThis: const(0),
			ifThat: const(1),
			ifBoth: const(1)
		)
	}
	
	public func find(_ predicate: (ThatType) -> Bool) throws -> ThatType? {
		return these(
			ifThis: const(nil),
			ifThat: { predicate($0) ? $0 : nil },
			ifBoth: { predicate($1) ? $1 : nil }
		)
	}
	
	public func toList() -> [ThatType] {
		return these(
			ifThis: const([]),
			ifThat: { [$0] },
			ifBoth: { [$1] }
		)
	}
}

// MARK: - These: Semigroup (This, That : Semigroup)

public extension TheseType where ThisType: Semigroup, ThatType: Semigroup {
	public func mappend(_ x: Self) -> Self {
		return these(
			ifThis: { a in
				return x.these(
					ifThis: { Self(this: a <> $0) },
					ifThat: { Self(this: a, that: $0) },
					ifBoth: { Self(this: a <> $0, that: $1) }
				)
			},
			ifThat: { b in
				return x.these(
					ifThis: { Self(this: $0, that: b) },
					ifThat: { Self(that: b <> $0) },
					ifBoth: { Self(this: $0, that: b <> $1) }
				)
			},
			ifBoth: { a, b in
				return x.these(
					ifThis: { Self(this: a <> $0, that: b) },
					ifThat: { Self(this: a, that: b <> $0) },
					ifBoth: { Self(this: a <> $0, that: b <> $1) }
				)
			}
		)
	}
}

public func <> <TT: TheseType where TT.ThisType: Semigroup, TT.ThatType: Semigroup>(_ lhs: TT, _ rhs: TT) -> TT {
	return lhs.mappend(rhs)
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

// MARK: - TheseType - map/flatMap/ap

public extension TheseType {
	public func map<T>(_ f: (ThisType) -> T) -> These<T, ThatType> {
		return bimap(f, id)
	}
	
	public func map<T>(_ f: (ThatType) -> T) -> These<ThisType, T> {
		return bimap(id, f)
	}
	
	public func bimap<T, U>(_ f: (ThisType) -> T, _ g: (ThatType) -> U) -> These<T, U> {
		return these(
			ifThis: { These(this: f($0)) },
			ifThat: { These(that: g($0)) },
			ifBoth: { These(this: f($0), that: g($1)) })
	}
}

// MARK; - These

public enum These<A, B> {
	case this(A)
	case that(B)
	case both(A, B)
}

// MARK: - These: TheseType

extension These: TheseType {
	public typealias ThisType = A
	public typealias ThatType = B
	
	public init(this: A) {
		self = .this(this)
	}
	
	public init(that: B) {
		self = .that(that)
	}
	
	public init(this: A, that: B) {
		self = .both(this, that)
	}
	
	public func these<T>(ifThis: @noescape (A) throws -> T, ifThat: @noescape (B) throws -> T, ifBoth: @noescape (A, B) throws -> T) rethrows -> T {
		switch self {
		case .this(let a):
			return try ifThis(a)
		case .that(let b):
			return try ifThat(b)
		case .both(let a, let b):
			return try ifBoth(a, b)
		}
	}
}

// MARK: These: Pointed

extension These: Pointed {
	public typealias Value = B
}
