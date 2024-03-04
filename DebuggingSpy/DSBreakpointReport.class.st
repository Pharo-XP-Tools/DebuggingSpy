Class {
	#name : #DSBreakpointReport,
	#superclass : #DSExceptionReport,
	#instVars : [
		'targets'
	],
	#category : #'DebuggingSpy-Records-Extensions'
}

{ #category : #adding }
DSBreakpointReport >> add: aBreakpointRecord [

	super add: aBreakpointRecord.
	aBreakpointRecord submethodTargets do: [ :target |
		(self targets at: target ifAbsentPut: [ OrderedCollection new ]) add:
			aBreakpointRecord ]
]

{ #category : #printing }
DSBreakpointReport >> printOn: aStream [

	super printOn: aStream.
	aStream space.
	aStream << 'breakpoints on'.
	aStream space.
	aStream << targets size asString.
	aStream space.
	aStream << 'submethod targets'
]

{ #category : #accessing }
DSBreakpointReport >> targets [

	^ targets ifNil: [ targets := Dictionary new ]
]

{ #category : #accessing }
DSBreakpointReport >> targets: anObject [

	targets := anObject
]
