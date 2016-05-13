//  Copyright © 2016 Yoshiki Kudo. All rights reserved.

// MARK: - Semigroup

public protocol Semigroup {
	func mappend(x: Self) -> Self
}

public func <> <S: Semigroup>(lhs: S, rhs: S) -> S {
	return lhs.mappend(rhs)
}
