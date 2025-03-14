"
I record debugger events triggered from users' interaction with the debugger.
I store the browsed debugger context: the executed method and the node that is going to be executed next.
"
Class {
	#name : 'DSDebuggerRecord',
	#superclass : 'DSAbstractEventRecord',
	#instVars : [
		'contextName',
		'sourceNodeClass',
		'sourceNodeCode'
	],
	#category : 'DebuggingSpy-Records',
	#package : 'DebuggingSpy',
	#tag : 'Records'
}

{ #category : 'accessing' }
DSDebuggerRecord >> contextName [

	^ contextName
]

{ #category : 'accessing' }
DSDebuggerRecord >> contextName: anObject [

	contextName := anObject
]

{ #category : 'actions api' }
DSDebuggerRecord >> record: aContextAndWindow [ 
	|aContext method sourceNode|
	super record: aContextAndWindow second.
	aContext := aContextAndWindow first.
	method := aContext method.
	contextName := method isCompiledBlock ifTrue:[method printString] ifFalse:[method name].
	sourceNode := aContext sourceNodeExecuted.
	sourceNodeClass := sourceNode class name.
	sourceNodeCode := sourceNode sourceCode
]

{ #category : 'accessing' }
DSDebuggerRecord >> sourceNodeClass [

	^ sourceNodeClass
]

{ #category : 'accessing' }
DSDebuggerRecord >> sourceNodeClass: anObject [

	sourceNodeClass := anObject
]

{ #category : 'accessing' }
DSDebuggerRecord >> sourceNodeCode [

	^ sourceNodeCode
]

{ #category : 'accessing' }
DSDebuggerRecord >> sourceNodeCode: anObject [

	sourceNodeCode := anObject
]
