"
I am a class that uses the filters defined in a record class to anonymize it.
"
Class {
	#name : 'DSRecordAnonymizer',
	#superclass : 'Object',
	#category : 'DebuggingSpy-Anonymizer-filters',
	#package : 'DebuggingSpy-Anonymizer',
	#tag : 'filters'
}

{ #category : 'processing' }
DSRecordAnonymizer class >> anonymize: aRecord [

	^ aRecord class anonymousFilter applyOn: aRecord
]
