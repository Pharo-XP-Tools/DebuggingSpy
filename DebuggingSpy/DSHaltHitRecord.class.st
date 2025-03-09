"
I record a halt hitting at run time.
"
Class {
	#name : 'DSHaltHitRecord',
	#superclass : 'DSAbstractHaltRecord',
	#instVars : [
		'once',
		'conditional',
		'selector'
	],
	#category : 'DebuggingSpy-Records',
	#package : 'DebuggingSpy',
	#tag : 'Records'
}

{ #category : 'accessing' }
DSHaltHitRecord >> conditional [

	^ conditional
]

{ #category : 'accessing' }
DSHaltHitRecord >> eventName [
	^'HALT_HIT (', method, ')'
]

{ #category : 'accessing' }
DSHaltHitRecord >> once [

	^ once
]

{ #category : 'actions api' }
DSHaltHitRecord >> record: anRBProgramNodeAndASelector [
	once := false.
	conditional := false.
	super record: anRBProgramNodeAndASelector first.
	selector := anRBProgramNodeAndASelector second.
	selector = #once ifTrue:[once := true].
	selector = #haltIf: ifTrue:[conditional := true]
	
]

{ #category : 'accessing' }
DSHaltHitRecord >> selector [

	^ selector
]
