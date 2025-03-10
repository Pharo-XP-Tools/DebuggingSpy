"
I record breakpoint events information, whatever the type of breakpoint.
My subclasses have to handle the real recording, depending on the breakpoint.
"
Class {
	#name : 'DSAbstractBreakpointEventRecord',
	#superclass : 'DSAbstractEventRecord',
	#instVars : [
		'target',
		'objectCentric',
		'eventName',
		'once',
		'breakpointHash'
	],
	#category : 'DebuggingSpy-Records',
	#package : 'DebuggingSpy',
	#tag : 'Records'
}

{ #category : 'converting' }
DSAbstractBreakpointEventRecord >> asBreakpointRecord [

	^ self modelClass
		  perform: eventName asLowercase asSymbol asMutator
		  with: self
]

{ #category : 'accessing' }
DSAbstractBreakpointEventRecord >> breakpointHash [
	^breakpointHash
]

{ #category : 'testing' }
DSAbstractBreakpointEventRecord >> canOpenDebuggers [
	^eventName = 'BreakpointHit'
]

{ #category : 'accessing' }
DSAbstractBreakpointEventRecord >> eventName [
	^eventName
]

{ #category : 'converting' }
DSAbstractBreakpointEventRecord >> modelClass [

	^ self subclassResponsibility
]

{ #category : 'accessing' }
DSAbstractBreakpointEventRecord >> objectCentric [

	^ objectCentric
]

{ #category : 'accessing' }
DSAbstractBreakpointEventRecord >> once [
	^ once
]

{ #category : 'printing' }
DSAbstractBreakpointEventRecord >> printTargetInstance: anObject [

	| str |
	str := WriteStream on: String new.
	str << '['.
	str << anObject identityHash printString.
	str << '] instance of '.
	str space.
	str << anObject class name.
	^ str contents
]

{ #category : 'actions api' }
DSAbstractBreakpointEventRecord >> record: aBreakpointEvent [

	eventName := aBreakpointEvent class name.
	objectCentric := aBreakpointEvent breakpoint isObjectCentric.
	target := objectCentric
		          ifTrue: [
			          self printTargetInstance:
				          aBreakpointEvent breakpoint targetInstance ]
		          ifFalse: [ nil ].
	once := aBreakpointEvent breakpoint once.
	breakpointHash := aBreakpointEvent breakpoint hash
]

{ #category : 'accessing' }
DSAbstractBreakpointEventRecord >> target [

	^ target
]
