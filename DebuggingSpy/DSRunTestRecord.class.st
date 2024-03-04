Class {
	#name : #DSRunTestRecord,
	#superclass : #DSAbstractExtendedRecord,
	#category : #'DebuggingSpy-Records-Extensions'
}

{ #category : #accessing }
DSRunTestRecord >> eventName [

	^ String streamContents: [ :str |
		  str << 'Running test:'.
		  str space.
		  str << sourceRecord itemElement ]
]
