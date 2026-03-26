"
I record unhandled exceptions with their context information
"
Class {
	#name : 'DSUnhandledExceptionRecord',
	#superclass : 'DSAbstractEventRecord',
	#instVars : [
		'exceptionClass',
		'errorString',
		'receiver',
		'node',
		'method'
	],
	#category : 'DebuggingSpy-Records',
	#package : 'DebuggingSpy',
	#tag : 'Records'
}

{ #category : 'accessing' }
DSUnhandledExceptionRecord >> errorString [
	^ errorString
]

{ #category : 'accessing' }
DSUnhandledExceptionRecord >> eventName [
	^exceptionClass 
]

{ #category : 'accessing' }
DSUnhandledExceptionRecord >> exceptionClass [
	^ exceptionClass
]

{ #category : 'accessing' }
DSUnhandledExceptionRecord >> method [
	^ method
]

{ #category : 'accessing' }
DSUnhandledExceptionRecord >> node [
	^ node
]

{ #category : 'accessing' }
DSUnhandledExceptionRecord >> receiver [
	^ receiver
]

{ #category : 'actions api' }
DSUnhandledExceptionRecord >> record: anException [

	| signalerContext |
	signalerContext := anException signalerContext.
	[ signalerContext method pragmas anySatisfy: [ :p | p selector = #debuggerCompleteToSender ] ] whileTrue: [
		signalerContext := signalerContext sender ].

	receiver := signalerContext receiver class name.
	node := (signalerContext method sourceNodeForPC: signalerContext pc) sourceCode.
	method := signalerContext method selector.
	exceptionClass := anException class name.
	errorString := anException description
]
