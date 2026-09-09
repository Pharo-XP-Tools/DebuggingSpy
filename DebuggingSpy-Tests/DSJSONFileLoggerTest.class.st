Class {
	#name : 'DSJSONFileLoggerTest',
	#superclass : 'TestCase',
	#category : 'DebuggingSpy-Tests',
	#package : 'DebuggingSpy-Tests'
}

{ #category : 'tests' }
DSJSONFileLoggerTest >> testDictToObject [

	| complexObjectDict result_object |
	complexObjectDict := {
		                     42.
		                     'testString'.
		                     {
			                     ('name' -> 'DSTestRecord').
			                     ('attributes' -> {
				                      ('dateTime' -> {
					                       ('name' -> 'DateAndTime').
					                       ('attributes' -> {
						                        ('seconds' -> 76354).
						                        ('julianDayNumber' -> 2461164).
						                        ('offset' -> {
							                         ('name' -> 'Duration').
							                         ('attributes' -> {
								                          ('seconds' -> 7200).
								                          ('nanos' -> 0) } asDictionary) } asDictionary) } asDictionary) } asDictionary).
				                      ('uuid' -> 1).
				                      ('first' -> 'firstAttribute').
				                      ('second' -> 26) } asDictionary) } asDictionary.
		                     {
			                     ('apple' -> 3).
			                     ('banana' -> 43).
			                     ('cherry' -> 18) } asDictionary }.

	result_object := DSJSONFileLogger dictToObject: complexObjectDict.

	self assert: result_object isArray.
	self assert: result_object size equals: 4.
	self assert: result_object first equals: 42.
	self assert: result_object second equals: 'testString'.
	self assert: result_object third class equals: DSTestRecord.
	self assert: result_object third dateTime class equals: DateAndTime.
	self assert: result_object third dateTime asString equals: '2026-05-03T23:12:34+02:00'.
	self assert: result_object third uuid equals: 1.
	self assert: result_object third first equals: 'firstAttribute'.
	self assert: result_object third second equals: 26.
	self assert: result_object fourth equals: {
			('apple' -> 3).
			('banana' -> 43).
			('cherry' -> 18) } asDictionary
]

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
