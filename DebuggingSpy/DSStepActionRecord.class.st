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
		'eventName',
		'receiver',
		'receiverClass'
	],
	#category : #'DebuggingSpy-Records'
}

{ #category : #converting }
DSStepActionRecord >> asStepRecord [

	^ DSStepRecord
		  perform:
			  (eventName asLowercase copyReplaceAll: ' ' with: '') asSymbol
				  asMutator
		  with: self 
]

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

{ #category : #accessing }
DSStepActionRecord >> receiver [

	^ receiver
]

{ #category : #accessing }
DSStepActionRecord >> receiverClass [

	^ receiverClass
]

{ #category : #'actions api' }
DSStepActionRecord >> record: aDSDebuggerCommand [
	super record: aDSDebuggerCommand context window window.
	eventName := aDSDebuggerCommand class defaultName.
	context := aDSDebuggerCommand context currentContext printString.
	node := aDSDebuggerCommand context currentContext sourceNodeExecuted printString.
	receiver := aDSDebuggerCommand context currentContext receiver printString.
	receiverClass := aDSDebuggerCommand context currentContext receiver class name
]
