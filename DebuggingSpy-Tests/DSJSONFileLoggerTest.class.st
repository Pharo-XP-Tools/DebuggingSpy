Class {
	#name : 'DSJSONFileLoggerTest',
	#superclass : 'TestCase',
	#category : 'DebuggingSpy-Tests',
	#package : 'DebuggingSpy-Tests'
}

{ #category : 'tests' }
DSJSONFileLoggerTest >> testObjectToDict [

	| complexObject result_dict |
	complexObject := {
		                 42.
		                 'testString'.
		                 (DSTestRecord new
			                  first: 'firstAttribute';
			                  second: 26).
		                 {
			                 ('apple' -> 3).
			                 ('banana' -> 43).
			                 ('cherry' -> 18) } asDictionary }.

	result_dict := DSJSONFileLogger objectToDict: complexObject.

	self assert: result_dict isArray.
	self assert: result_dict size equals: 4.
	self assert: result_dict first equals: 42.
	self assert: result_dict second equals: 'testString'.
	self assert: (result_dict third at: 'name') equals: 'DSTestRecord'.
	self assert: ((result_dict third at: 'attributes') at: 'first') equals: 'firstAttribute'.
	self assert: ((result_dict third at: 'attributes') at: 'second') equals: 26.
	self assert: result_dict fourth equals: {
			('apple' -> 3).
			('banana' -> 43).
			('cherry' -> 18) } asDictionary
]
