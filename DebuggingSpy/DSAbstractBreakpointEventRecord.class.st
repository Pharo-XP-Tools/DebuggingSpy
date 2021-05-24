"
I record breakpoint events information, whatever the type of breakpoint.
My subclasses have to handle the real recording, depending on the breakpoint.
"
Class {
	#name : #DSAbstractBreakpointEventRecord,
	#superclass : #DSAbstractEventRecord,
	#instVars : [
		'target',
		'objectCentric',
		'eventName',
		'once'
	],
	#category : #'DebuggingSpy-Records'
}

{ #category : #accessing }
DSAbstractBreakpointEventRecord >> eventName [
	^eventName
]

{ #category : #accessing }
DSAbstractBreakpointEventRecord >> objectCentric [

	^ objectCentric
]

{ #category : #accessing }
DSAbstractBreakpointEventRecord >> once [
	^ once
]

{ #category : #printing }
DSAbstractBreakpointEventRecord >> printTargetInstance: anObject [

	| str |
	str := WriteStream on: String new.
	str << '['.
	str << anObject hash printString.
	str << ']'.
	str space.
	str << anObject printString.
	^ str contents
]

{ #category : #'actions api' }
DSAbstractBreakpointEventRecord >> record: aBreakpointEvent [

	eventName := aBreakpointEvent class name.
	objectCentric := aBreakpointEvent breakpoint isObjectCentric.
	target := objectCentric
		          ifTrue: [ 
			          self printTargetInstance:
				          aBreakpointEvent breakpoint targetInstance ]
		          ifFalse: [ nil ].
	once := aBreakpointEvent breakpoint oneShot
]

{ #category : #accessing }
DSAbstractBreakpointEventRecord >> target [

	^ target
]
