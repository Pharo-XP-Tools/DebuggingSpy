"
I record unhandled exceptions with their context information
"
Class {
	#name : #DSUnhandledExceptionRecord,
	#superclass : #DSAbstractEventRecord,
	#instVars : [
		'exceptionClass',
		'errorString',
		'receiver',
		'node',
		'method'
	],
	#category : #'DebuggingSpy-Records'
}

{ #category : #accessing }
DSUnhandledExceptionRecord >> errorString [
	^ errorString
]

{ #category : #accessing }
DSUnhandledExceptionRecord >> eventName [
	^exceptionClass 
]

{ #category : #accessing }
DSUnhandledExceptionRecord >> exceptionClass [
	^ exceptionClass
]

{ #category : #accessing }
DSUnhandledExceptionRecord >> method [
	^ method
]

{ #category : #accessing }
DSUnhandledExceptionRecord >> node [
	^ node
]

{ #category : #accessing }
DSUnhandledExceptionRecord >> receiver [
	^ receiver
]

{ #category : #'actions api' }
DSUnhandledExceptionRecord >> record: anException [

	|signalerContext context|
	signalerContext := anException signalerContext.
	receiver := signalerContext receiver class name.
		
	context := signalerContext.
	[ context method pragmas anySatisfy: [ :p| p selector = #debuggerCompleteToSender ] ] 
		whileTrue:[context := signalerContext sender.].	
	node := (context method sourceNodeForPC: context pc) sourceCode.
	method := context method selector.
	
	exceptionClass := anException class name.
	errorString := anException description
]
