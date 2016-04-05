"Try represents a computation that results in a succesfully computed value or an `Exception`.
 
 This makes explicit the error handling of such computation and also provides combinators to compose operations.
 
 Note that most operations return a _new_ instance but the computation result is not copied but passed to this new instance.
"
by ("Miguel Enriquez")
shared class Try<out Result> {
	
	late Result|Exception computationResult;
	
	"Creates an instance by running the given computation"
	shared new (Result() computation) {
		
		try {
			this.computationResult = computation();
		} catch (Exception e) {
			this.computationResult = e;
		}
	}
	
	"Convenient constructor to create an instance with a value or an Exception"
	shared new withComputationResult(Result|Exception resultOrException) {
		this.computationResult = resultOrException;
	}
	
	"Returns the result of the computation."
	shared Result|Exception result() => this.computationResult;
	
	"Applies the [[mappingFunction]] to the result of the computation if and only if the computation was successful and returns a new [[Try]] instance.
	                                                                   If the mapping function fails i.e. throws an Exception, this Exception is given as the result of the new instance returned."
	shared Try<MappingResult> map<MappingResult>(MappingResult(Result) mappingFunction) {
		if (is Exception computationResult) {
			return Try<MappingResult>.withComputationResult(computationResult);
		}
		
		try {
			value mappingResult = mappingFunction(computationResult);
			return Try<MappingResult>.withComputationResult(mappingResult);
		} catch (Exception e) {
			return Try<MappingResult>.withComputationResult(e);
		}
	}
	
	"Returns the result of the [[mappingFunction]] provided or an instance with an Exception if an error results"
	shared Try<MappingResult> flatMap<MappingResult>(Try<MappingResult>(Result) mappingFunction) {
		if (is Exception computationResult) {
			return Try<MappingResult>.withComputationResult(computationResult);
		}
		
		try {
			return mappingFunction(computationResult);
		} catch (Exception e) {
			return Try<MappingResult>.withComputationResult(e);
		}
	}
	
	"Returns a new instance containing the result if the [[predicate]] returns true else it returns 
	                                     an instance with an Exception as result unless the result was already an Exception."
	shared Try<Result> filter(Boolean(Result) predicate) {
		if (is Exception computationResult) {
			return Try<Result>.withComputationResult(computationResult);
		}
		
		try {
			value predicateHolds = predicate(computationResult);
			
			if (predicateHolds) {
				return Try.withComputationResult(computationResult);
			} else {
				value stringRepresentation = if (exists computationResult) then computationResult.string else "null";
				return Try<Result>.withComputationResult(Exception("Predicate does not hold for value [``stringRepresentation``]"));
			}
		} catch (Exception e) {
			return Try<Result>.withComputationResult(e);
		}
	}
	
	shared Try<Result|RecoverValue> recoverWith<RecoverValue>(RecoverValue|RecoverValue(Exception) recover) {
		if (is Result computationResult) {
			return Try.withComputationResult(computationResult);
		}
		
		try {
			
			if (is RecoverValue recover) {
				return Try.withComputationResult(recover);
			} else {
				value recoveryValue = recover(computationResult);
				return Try.withComputationResult(recoveryValue);
			}
		} catch (Exception e) {
			return Try<Result|RecoverValue>.withComputationResult(e);
		}
	}
}
