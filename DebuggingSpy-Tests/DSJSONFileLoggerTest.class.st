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
				                      ('uuid' -> {
					                       ('name' -> 'UUID').
					                       ('attributes' -> { ('uuidData' -> { ('ByteArray' -> { 34. 45. 21. 67 }) } asDictionary) } asDictionary) }
					                       asDictionary).
				                      ('first' -> 'firstAttribute').
				                      ('second' -> 26) } asDictionary) } asDictionary.
		                     {
			                     ('apple' -> 3).
			                     ('banana' -> 43).
			                     ('cherry' -> 18) } asDictionary.
		                     { ('class' -> 'DSTestTask') } asDictionary }.

	result_object := DSJSONFileLogger dictToObject: complexObjectDict.

	self assert: result_object isArray.
	self assert: result_object size equals: 5.
	self assert: result_object first equals: 42.
	self assert: result_object second equals: 'testString'.
	self assert: result_object third class equals: DSTestRecord.
	self assert: result_object third dateTime class equals: DateAndTime.
	self assert: result_object third dateTime asString equals: '2026-05-03T23:12:34+02:00'.
	self assert: result_object third uuid class equals: UUID.
	self assert: result_object third uuid uuidData equals: { 34. 45. 21. 67 } asByteArray.
	self assert: result_object third first equals: 'firstAttribute'.
	self assert: result_object third second equals: 26.
	self assert: result_object fourth equals: {
			('apple' -> 3).
			('banana' -> 43).
			('cherry' -> 18) } asDictionary.
	self assert: result_object fifth equals: DSTestTask
]

{ #category : 'tests' }
DSJSONFileLoggerTest >> testIsByteArray [

	| byteArrayDict otherDict objectDict |
	byteArrayDict := { ('ByteArray' -> [
		                  12.
		                  56.
		                  89 ]) } asDictionary.
	otherDict := {
		             ('firstkey' -> 'something').
		             ('secondkey' -> 93) } asDictionary.
	objectDict := {
		              ('name' -> 'MyObject').
		              ('attributes' -> {
			               ('first' -> 42).
			               ('second' -> 'goodOne') } asDictionary) } asDictionary.

	self assert: (DSJSONFileLogger isByteArray: byteArrayDict).
	self deny: (DSJSONFileLogger isByteArray: otherDict).
	self deny: (DSJSONFileLogger isByteArray: objectDict)
]

{ #category : 'tests' }
DSJSONFileLoggerTest >> testIsJSONClass [

	| byteArrayDict otherDict objectDict jsonClassDict |
	byteArrayDict := { ('ByteArray' -> [
		                  12.
		                  56.
		                  89 ]) } asDictionary.
	otherDict := {
		             ('firstkey' -> 'something').
		             ('secondkey' -> 93) } asDictionary.
	objectDict := {
		              ('name' -> 'MyObject').
		              ('attributes' -> {
			               ('first' -> 42).
			               ('second' -> 'goodOne') } asDictionary) } asDictionary.

	jsonClassDict := { ('class' -> 'UUID') } asDictionary.

	self deny: (DSJSONFileLogger isJSONClass: byteArrayDict).
	self deny: (DSJSONFileLogger isJSONClass: otherDict).
	self deny: (DSJSONFileLogger isJSONClass: objectDict).
	self assert: (DSJSONFileLogger isJSONClass: jsonClassDict)
]

{ #category : 'tests' }
DSJSONFileLoggerTest >> testIsJSONObject [

	| byteArrayDict otherDict objectDict jsonClassDict |
	byteArrayDict := { ('ByteArray' -> [
		                  12.
		                  56.
		                  89 ]) } asDictionary.
	otherDict := {
		             ('firstkey' -> 'something').
		             ('secondkey' -> 93) } asDictionary.
	objectDict := {
		              ('name' -> 'MyObject').
		              ('attributes' -> {
			               ('first' -> 42).
			               ('second' -> 'goodOne') } asDictionary) } asDictionary.

	jsonClassDict := { ('class' -> 'UUID') } asDictionary.

	self deny: (DSJSONFileLogger isJSONObject: byteArrayDict).
	self deny: (DSJSONFileLogger isJSONObject: otherDict).
	self assert: (DSJSONFileLogger isJSONObject: objectDict).
	self deny: (DSJSONFileLogger isJSONObject: jsonClassDict)
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
			                 ('cherry' -> 18) } asDictionary.
		                 DSTestTask.
		                 (UUID new uuidData: { 32. 46. 68. 93 } asByteArray) }.

	result_dict := DSJSONFileLogger objectToDict: complexObject.

	self assert: result_dict isArray.
	self assert: result_dict size equals: 6.
	self assert: result_dict first equals: 42.
	self assert: result_dict second equals: 'testString'.
	self assert: (result_dict third at: 'name') equals: 'DSTestRecord'.
	self assert: ((result_dict third at: 'attributes') at: 'first') equals: 'firstAttribute'.
	self assert: ((result_dict third at: 'attributes') at: 'second') equals: 26.
	self assert: result_dict fourth equals: {
			('apple' -> 3).
			('banana' -> 43).
			('cherry' -> 18) } asDictionary.
	self assert: result_dict fifth equals: { ('class' -> 'DSTestTask') } asDictionary.
	self assert: (result_dict sixth at: 'name') equals: 'UUID'.
	self assert: ((result_dict sixth at: 'attributes') at: 'uuidData') equals: { ('ByteArray' -> { 32. 46. 68. 93 }) } asDictionary
]

{ #category : 'tests' }
DSJSONFileLoggerTest >> testToJSON [

	| firstObject secondObject |
	firstObject := UUID new uuidData: { 48. 207. 102. 51. 23. 89 } asByteArray.
	secondObject := DSTestObject new
		                first: 'someAttribute';
		                second: 42;
		                other: { 'hey'. 26. 'bonjour' }.

	self
		assert: (DSJSONFileLogger toJSON: firstObject)
		equals: '{"attributes":{"uuidData":{"ByteArray":[48,207,102,51,23,89]}},"name":"UUID"}'.
	self
		assert: (DSJSONFileLogger toJSON: secondObject)
		equals: '{"attributes":{"second":42,"other":["hey",26,"bonjour"],"first":"someAttribute"},"name":"DSTestObject"}'
]

{ #category : 'tests' }
DSJSONFileLoggerTest >> testTranslateByteArray [

	| firstByteArray secondByteArray |
	firstByteArray := { ('ByteArray' -> { 23. 56. 89 }) } asDictionary.
	secondByteArray := { ('ByteArray' -> { 12. 76. 43 }) } asDictionary.

	self assert: (DSJSONFileLogger translateByteArray: firstByteArray) equals: { 23. 56. 89 } asByteArray.
	self assert: (DSJSONFileLogger translateByteArray: secondByteArray) equals: { 12. 76. 43 } asByteArray
]

{ #category : 'tests' }
DSJSONFileLoggerTest >> testTranslateJSONClass [

	| firstClass secondClass thirdClass |
	firstClass := { ('class' -> 'UUID') } asDictionary.
	secondClass := { ('class' -> 'Array') } asDictionary.
	thirdClass := { ('class' -> 'StPresenter') } asDictionary.

	self assert: (DSJSONFileLogger translateJSONClass: firstClass) equals: UUID.
	self assert: (DSJSONFileLogger translateJSONClass: secondClass) equals: Array.
	self assert: (DSJSONFileLogger translateJSONClass: thirdClass) equals: StPresenter
]

{ #category : 'tests' }
DSJSONFileLoggerTest >> testTranslateJSONObject [

	| firstJSONObject secondJSONObject thirdJSONObject firstObject secondObject thirdObject |
	firstJSONObject := {
		                   ('name' -> 'UUID').
		                   ('attributes' -> { ('uuidData' -> { ('ByteArray' -> { 12. 56. 82 }) } asDictionary) } asDictionary) }
		                   asDictionary.
	secondJSONObject := {
		                    ('name' -> 'DateAndTime').
		                    ('attributes' -> {
			                     ('seconds' -> 76416).
			                     ('julianDayNumber' -> 2461174).
			                     ('offset' -> {
				                      ('name' -> 'Duration').
				                      ('attributes' -> {
					                       ('seconds' -> 3600).
					                       ('nanos' -> 0) } asDictionary) } asDictionary) } asDictionary) } asDictionary.
	thirdJSONObject := {
		                   ('name' -> 'DSTestObject').
		                   ('attributes' -> {
			                    ('first' -> 34).
			                    ('second' -> 'anAttribute').
			                    ('other' -> 'anOtherOne') } asDictionary) } asDictionary.

	firstObject := DSJSONFileLogger translateJSONObject: firstJSONObject.
	secondObject := DSJSONFileLogger translateJSONObject: secondJSONObject.
	thirdObject := DSJSONFileLogger translateJSONObject: thirdJSONObject.

	self assert: firstObject class equals: UUID.
	self assert: firstObject uuidData equals: { 12. 56. 82 } asByteArray.
	self assert: secondObject class equals: DateAndTime.
	self assert: secondObject asString equals: '2026-05-13T22:13:36+01:00'.
	self assert: thirdObject class equals: DSTestObject.
	self assert: thirdObject first equals: 34.
	self assert: thirdObject second equals: 'anAttribute'.
	self assert: thirdObject other equals: 'anOtherOne'
]

{ #category : 'tests' }
DSJSONFileLoggerTest >> testfromJSON [

	| firstJSON secondJSON secondObject |
	firstJSON := '{"attributes":{"uuidData":{"ByteArray":[187,20,34,215,9]}},"name":"UUID"}'.
	secondJSON := '{"attributes":{"second":870,"other":["hallo","salut",67],"first":"myAttribute"},"name":"DSTestObject"}'.

	secondObject := DSJSONFileLogger fromJSON: secondJSON.

	self assert: (DSJSONFileLogger fromJSON: firstJSON) equals: (UUID new uuidData: { 187. 20. 34. 215. 9 } asByteArray).
	self assert: secondObject class equals: DSTestObject.
	self assert: secondObject first equals: 'myAttribute'.
	self assert: secondObject second equals: 870.
	self assert: secondObject other equals: { 'hallo'. 'salut'. 67 }
]
