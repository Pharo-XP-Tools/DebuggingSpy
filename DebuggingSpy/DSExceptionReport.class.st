Class {
	#name : #DSExceptionReport,
	#superclass : #Object,
	#instVars : [
		'records',
		'method'
	],
	#category : #'DebuggingSpy-Records-Extensions'
}

{ #category : #adding }
DSExceptionReport >> add: aBreakpointRecord [

	self records add: aBreakpointRecord
]

{ #category : #accessing }
DSExceptionReport >> method [

	^ method
]

{ #category : #accessing }
DSExceptionReport >> method: anObject [

	method := anObject
]

{ #category : #printing }
DSExceptionReport >> printOn: aStream [

	aStream << method.
	aStream << ':'.
	aStream space.
	aStream << records size asString
]

{ #category : #accessing }
DSExceptionReport >> records [

	^ records ifNil: [ records := OrderedCollection new ]
]

{ #category : #accessing }
DSExceptionReport >> records: anObject [

	records := anObject
]
