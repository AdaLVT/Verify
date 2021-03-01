//module verify.Proof;

import Expression, std.variant;
	import std.stdio, std.conv;

enum ProofType { WFF, Assumption, Set, Class }
string surround(ProofType type, string arg) {
	if(type == ProofType.WFF) {
		return "\\lBrack " ~ arg ~ " \\rBrack";
	} else if(type == ProofType.Assumption) {
		return "\\lParen " ~ arg ~ " \\rParen";
	} else if(type == ProofType.Set) {
		return "\\lBrace " ~ arg ~ " \\rBrace";
	} else if(type == ProofType.Class) {
		return "\\lAngle " ~ arg ~ " \\rAngle";
	} else {
		assert(false, "Let Ada know she's an idiot");
	}
}

int[] nextAts(int[] arg) {
	int[] res;
	foreach(int i; arg) {
		res ~= i;
	}
	res[$-1] += 1;
	return res;
}

class Proof { //The actual proof object
	private string name; //The name when referenced
	public string getName() {
		return this.name;
	}

	private ProofType proofType;
	public bool isWFF() {
		return this.proofType == ProofType.WFF;
	}
	public bool isAssumption() {
		return this.proofType == ProofType.Assumption;
	}
	public bool isSet() {
		return this.proofType == ProofType.Set;
	}
	public bool isClass() {
		return this.proofType == ProofType.Class;
	}

	private Expression expression;
	public Expression getExpression() {
		return this.expression;
	}

	private Algebraic!(Proof[], int[]) reason; //The reasons used to arrive at this step
	public Algebraic!(Proof[], int[]) getReason() {
		return this.reason;
	}

	this(string name, ProofType proofType, Expression expression, Proof[] reason = []) {
		this.name = name;
		this.proofType = proofType;
		this.expression = expression;
		this.reason = reason;
	}
	this(string name, ProofType proofType, Expression expression, int[] reason) {
		this.name = name;
		this.proofType = proofType;
		this.expression = expression;
		this.reason = reason;
	}

	public string getRep() {
		string res = this.expression.getRep();
		if(*this.reason.peek!(int[]) is null) {
			res ~= " \\\\\n\\because " ~ this.getName();
			for(int i = 0; i < this.reason.length; i++) {
				Proof R = (reason.get!(Proof[]))[i];
				res ~= R.getRep();
			}
		} else {
			res ~= this.expression.getRep(reason.get!(int[]));
		}
		return surround(this.proofType, res);
	}
}

//BEGIN TESTING

Proof wffTrue() {
	return new Proof("wffTrue", ProofType.WFF, atom("1"));
}

Proof wffNot(Proof phi) {
	assert(phi.isWFF, "Error: wffNot expects a WFF in position 1");
	return new Proof("wffNot", ProofType.WFF, not(phi.getExpression()), [phi]);
}

Proof wffNot_(Proof[] args) {
	return wffNot(args[0]);
}

string state(string name, Proof function(Proof[]) f, ProofType[] types, Expression[] args) {
	Proof[] res;
	for(int i = 0; i < args.length; i++) {
		res ~= new Proof(name, types[i], args[i], [i+1]);
	}
	Proof res2 = (*f)(res);
	string res3 = res2.getRep();
	return res3;
}
//XXX TODO FIXME: 1) This could be done much better
//2) I need to work on this a bit more
//3) It's not even usable right now. Segfaults!!!


Proof wffDN(Proof wffPhi) {
	return wffNot(wffNot(wffPhi));
}

void main() {
	auto T = wffTrue();
	writeln(wffNot(T).getRep());
	//writeln(state(name, &wffNot_, [ProofType.WFF], [atom("\\varphi")]));
}

//XXX TODO FIXME: This **ALL** needs to be rewritten, nice going not acommodating hypothesis references!
