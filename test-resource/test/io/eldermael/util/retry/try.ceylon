import ceylon.test {
	test
}
import io.eldermael.util.retry {
	Try
}

String successfulComputation() {
	return "success";
}

String failedComputation() {
	throw Exception("failed");
}

Integer getSize(String result) => result.size;

test
shared void shouldReturnResultIfSuccessfull() {
	// given
	value f = successfulComputation;
	
	//when
	value result = Try(f).result();
	
	// then
	assert (result == f());
}

test
shared void shouldReturnExceptionIfFailed() {
	// given
	value f = failedComputation;
	
	// when
	value result = Try(f).result();
	
	// then 
	assert (is Exception result);
}

test
shared void shouldMapValueIfSuccessfulComputation() {
	// given	
	value computation = Try(successfulComputation);
	
	// when		
	value mappedResult = computation.map(getSize).result();
	
	// then	
	assert (mappedResult == getSize(successfulComputation()));
}

test
shared void shouldReturnExceptionWhenTryingToMapFailedComputation() {
	// given
	value failedExecution = Try(failedComputation);
	
	// when
	value exception = failedExecution.map((result) => "should not be reached").result();
	
	// then
	assert (is Exception exception);
}

test
shared void shouldReturnRootExceptionWhenMappingValue() {
	// given
	value rootException = Exception("root");
	value failedComputation = Try(() { throw rootException; });
	
	// when 
	value exception = failedComputation.map((result) => "should not be reached").result();
	
	// then
	assert (rootException == exception);
}

test
shared void shouldReturnFirstExceptionWhenMappingValue() {
	// given
	value rootException = Exception("root");
	value lastException = Exception("last");
	value failedComputation = Try(() { throw rootException; });
	
	// when
	value exception = failedComputation.map((result) { throw lastException; }).result();
	
	// then
	assert (is Exception exception);
	assert (rootException == exception);
}

test
shared void shouldReturnMappedResultWhenFlatMapping() {
	// given
	value successfulTry = Try(successfulComputation);
	
	// when
	value flatMap = successfulTry.flatMap((result) => Try(() => getSize(result)));
	
	// then
	assert (flatMap.result() == getSize(successfulComputation()));
}

test
shared void shouldReturnExceptionWhenFlatMappingFails() {
	// given 
	value successfulTry = Try(successfulComputation);
	
	// when
	
	value flatMap = successfulTry.flatMap((result) {
			if (result.size > 0) {
				throw Exception("ouchies!");
			}
			return Try.withComputationResult(result);
		}).result();
	
	// then
	assert (is Exception flatMap, flatMap.message == "ouchies!");
}

test
shared void shouldReturnSameValueIfPredicateHoldsTrue() {
	// given
	value successfulTry = Try(successfulComputation);
	
	// when
	value filtered = successfulTry.filter((result) => true).result();
	
	// then
	assert (filtered == successfulComputation());
}

test
shared void shouldReturnExceptionIfPredicateFails() {
	// given
	value successfulTry = Try(successfulComputation);
	
	// when
	value filtered = successfulTry.filter((result) => false).result();
	
	// then
	assert (is Exception filtered);
}

test
shared void shouldReturnExceptionIfPredicateThrows() {
	// given
	value successfulTry = Try(successfulComputation);
	
	// when
	value filtered = successfulTry.filter((result) {
			if (result.size > 0) {
				throw Exception("ouchies!");
			}
			return true;
		}).result();
	
	// then
	assert (is Exception filtered, filtered.message == "ouchies!");
}
