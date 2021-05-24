"
I record a debugging action from an opened debugger.
In addition to the debugger window id, I also record the signature of the context I am performing the action as well as the current node of that context.
In confidentiality mode, this signature and node should be replaced by the current pc instead.
"
Class {
	#name : #DSStepActionRecord,
	#superclass : #DSAbstractEventRecord,
	#instVars : [
		'context',
		'node',
		'eventName'
	],
	#category : #'DebuggingSpy-Records'
}

{ #category : #accessing }
DSStepActionRecord >> context [

	^ context
]

{ #category : #accessing }
DSStepActionRecord >> eventName [
	^eventName
]

{ #category : #accessing }
DSStepActionRecord >> node [

	^ node
]

{ #category : #'actions api' }
DSStepActionRecord >> record: aDSDebuggerCommand [
	super record: aDSDebuggerCommand context window window.
	eventName := aDSDebuggerCommand class defaultName.
	context := aDSDebuggerCommand context currentContext printString.
	node := aDSDebuggerCommand context currentContext sourceNodeExecuted printString.
]
