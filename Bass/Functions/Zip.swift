//  Copyright © 2016 Yoshiki Kudo. All rights reserved.

public func zipWith<A: Collection, B: Collection, C>(f: (A.Iterator.Element) -> (B.Iterator.Element) -> C) -> (A) -> (B) -> [C] {
	return { a in
		{ b in
			return zip(a, b).map{ f($0)($1) }
		}
	}
}
