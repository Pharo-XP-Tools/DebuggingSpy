Class {
	#name : #DSBreakpointReport,
	#superclass : #Object,
	#instVars : [
		'records',
		'method',
		'targets'
	],
	#category : #'DebuggingSpy-Records-Extensions'
}

{ #category : #adding }
DSBreakpointReport >> add: aBreakpointRecord [

	self records add: aBreakpointRecord.
	aBreakpointRecord submethodTargets do: [ :target |
		(self targets at: target ifAbsentPut: [ OrderedCollection new ]) add:
			aBreakpointRecord ]
]

{ #category : #accessing }
DSBreakpointReport >> method [

	^ method
]

{ #category : #accessing }
DSBreakpointReport >> method: anObject [

	method := anObject
]

{ #category : #printing }
DSBreakpointReport >> printOn: aStream [

	aStream << method.
	aStream << ':'.
	aStream space.
	aStream << records size asString.
	aStream space.
	aStream << 'breakpoints on'.
	aStream space.
	aStream << targets size asString.
	aStream space.
	aStream << 'submethod targets'
]

{ #category : #accessing }
DSBreakpointReport >> records [

	^ records ifNil: [ records := OrderedCollection new ]
]

{ #category : #accessing }
DSBreakpointReport >> records: anObject [

	records := anObject
]

{ #category : #accessing }
DSBreakpointReport >> targets [

	^ targets ifNil: [ targets := Dictionary new ]
]

{ #category : #accessing }
DSBreakpointReport >> targets: anObject [

	targets := anObject
]
