//  Copyright © 2016 Yoshiki Kudo. All rights reserved.

public func zipWith<A: CollectionType, B: CollectionType, C>(f: A.Generator.Element -> B.Generator.Element -> C) -> A -> B -> [C] {
	return { a in
		{ b in
			return zip(a, b).map{ f($0)($1) }
		}
	}
}
