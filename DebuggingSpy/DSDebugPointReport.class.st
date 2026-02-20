Class {
	#name : 'DSDebugPointReport',
	#superclass : 'DSExceptionReport',
	#instVars : [
		'targets'
	],
	#category : 'DebuggingSpy-Records-Extensions',
	#package : 'DebuggingSpy',
	#tag : 'Records-Extensions'
}

{ #category : 'adding' }
DSDebugPointReport >> add: aDebugPointRecord [

	super add: aDebugPointRecord.
	aDebugPointRecord submethodTargets do: [ :target |
		(self targets at: target ifAbsentPut: [ OrderedCollection new ]) add:
			aDebugPointRecord ]
]

{ #category : 'printing' }
DSDebugPointReport >> printOn: aStream [

	super printOn: aStream.
	aStream space.
	aStream << 'breakpoints on'.
	aStream space.
	aStream << targets size asString.
	aStream space.
	aStream << 'submethod targets'
]

{ #category : 'accessing' }
DSDebugPointReport >> targets [

	^ targets ifNil: [ targets := Dictionary new ] ifNotNil: [ targets ]
]

{ #category : 'accessing' }
DSDebugPointReport >> targets: anObject [

	targets := anObject
]
