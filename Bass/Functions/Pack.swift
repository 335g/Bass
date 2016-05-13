//  Copyright © 2016 Yoshiki Kudo. All rights reserved.

public func pack<A, B, C>(t: (A, B), value: C) -> (A, B, C) {
	return (t.0, t.1, value)
}

public func pack<A, B, C, D>(t: (A, B, C), value: D) -> (A, B, C, D) {
	return (t.0, t.1, t.2, value)
}

public func pack<A, B, C, D, E>(t: (A, B, C, D), value: E) -> (A, B, C, D, E) {
	return (t.0, t.1, t.2, t.3, value)
}
