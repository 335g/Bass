//  Copyright © 2016 Yoshiki Kudo. All rights reserved.

extension Int: Semigroup {
	public func mappend(_ x: Int) -> Int {
		return self + x
	}
}

extension Int: Monoid {
	public static var mempty: Int {
		return 0
	}
}

extension Int: Foldable {
	public func foldr<T>(initial: T, _ f: (Int) -> (T) -> T) -> T {
		return f(self)(initial)
	}
}
