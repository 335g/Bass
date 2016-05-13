//  Copyright © 2016 Yoshiki Kudo. All rights reserved.

// MARK: - Monoid

public protocol Monoid: Semigroup {
	static var mempty: Self { get }
}
