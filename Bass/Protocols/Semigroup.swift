//  Copyright © 2016 Yoshiki Kudo. All rights reserved.

// MARK: - Semigroup

public protocol Semigroup {
	func mappend(_ x: Self) -> Self
}

public func <> <S: Semigroup>(_ lhs: S, _ rhs: S) -> S {
	return lhs.mappend(rhs)
}
