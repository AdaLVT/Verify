module Expression;

import std.conv;

interface Exp { //Used to implement the expression predicates
	public bool isAtomic();
	public bool isNegation();
	public bool isImplication();
}


abstract class Expression: Exp {
	private string rep; //The string representation of an expression
	private Expression[] arguments; //The arguments to the expression

	public string getRep() {
		import std.stdio;
		return this.rep;
	}
	public string getRep(int[] R) { //R: current reference number.
		string res;
		foreach(int i; R) {
			if(res != "")
				res ~= i.text;
			else
				res ~= "." ~ i.text;
		}
		return this.rep ~ " \\because \\mathbb{" ~ res ~ "}";
	}
	public Expression[] getArguments() {
		return this.arguments;
	}

}

class Atomic: Expression { //Used for variables, the empty set, etc.
	public bool isAtomic() { return true; }
	public bool isNegation() { return false; }
	public bool isImplication() { return false; }

	this(string rep) {
		this.rep = rep;
		this.arguments = [];
	}
}
Atomic atom(string arg) { //For ease of use, instead of having to do `new ...` and stuff
	return new Atomic(arg);
}

class Negation: Expression { //Logical NOT
	public bool isAtomic() { return false; }
	public bool isNegation() { return true; }
	public bool isImplication() { return false; }

	this(Expression arg) {
		//XXX: could use some tweaking to make operator precedence just a modify-once-then-done deal
		if(arg.isAtomic || arg.isNegation)
			this.rep = "\\lnot " ~ arg.rep;
		else
			this.rep = "\\lnot(" ~ arg.rep ~ ")";
		this.arguments = [arg];
	}
}
Negation not(Expression arg) {
	return new Negation(arg);
}

class Implication: Expression { //Logical implication
	public bool isAtomic() { return false; }
	public bool isNegation() { return false; }
	public bool isImplication() { return true; }
	this(Expression lhs, Expression rhs) {
		string lhsP, rhsP;
		if(this.isAtomic || lhs.isNegation)
			lhsP = lhs.rep;
		else
			lhsP = "(" ~ lhs.rep ~ ")";
		if(rhs.isAtomic || rhs.isNegation)
			rhsP = rhs.rep;
		else
			rhsP = "(" ~ rhs.rep ~ ")";
		this.rep = lhsP ~ "\\Leftrightarrow " ~ rhsP;
		this.arguments = [lhs, rhs];
	}
}
Implication implies(Expression lhs, Expression rhs) {
	return new Implication(lhs, rhs);
}
