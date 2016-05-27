//  Copyright © 2016 Yoshiki Kudo. All rights reserved.

@testable import Bass

enum Cont2<R, A> {
	typealias Function = (A -> R) -> R
}

func <^> <R, A, B>(f: A -> B, m: Cont2<R, A>.Function) -> Cont2<R, B>.Function {
	return { br in m(br • f) }
}

func >>- <R, A, B>(m: Cont2<R, A>.Function, fn: A -> Cont2<R, B>.Function) -> Cont2<R, B>.Function {
	return { c in m{ fn($0)(c) } }
}

func pure<R, A>(x: A) -> Cont2<R, A>.Function {
	return { f in f(x) }
}
