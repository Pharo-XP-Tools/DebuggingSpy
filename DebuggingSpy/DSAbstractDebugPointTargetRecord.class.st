"
I am an abstract class representing a record of a debugPoint's target.
"
Class {
	#name : 'DSAbstractDebugPointTargetRecord',
	#superclass : 'Object',
	#instVars : [
		'target'
	],
	#category : 'DebuggingSpy-Records-Extensions',
	#package : 'DebuggingSpy',
	#tag : 'Records-Extensions'
}

{ #category : 'instance creation' }
DSAbstractDebugPointTargetRecord class >> for: aDebugPointTarget [

	^ self new record: aDebugPointTarget 
]

{ #category : 'actions api' }
DSAbstractDebugPointTargetRecord >> record: aDebugPointTarget [

	target := aDebugPointTarget target asString
]

{ #category : 'accessing' }
DSAbstractDebugPointTargetRecord >> target [

	^ target
]
