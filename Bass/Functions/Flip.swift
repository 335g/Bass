//  Copyright © 2016 Yoshiki Kudo. All rights reserved.

public func flip<A, B, C>(f: A -> B -> C) -> B -> A -> C {
	return { b in { a in return f(a)(b) }}
}

public func flip<A, B, C, D>(f: A -> B -> C -> D) -> C -> B -> A -> D {
	return { c in { b in { a in f(a)(b)(c) }}}
}

public func flip<A, B, C, D, E>(f: A -> B -> C -> D -> E) -> D -> C -> B -> A -> E {
	return { d in { c in { b in { a in f(a)(b)(c)(d) }}}}
}
