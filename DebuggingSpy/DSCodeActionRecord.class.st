"
I record user debugging actions applied on code, such as debug it, doit, print it.
I store the code string on which the user applied that action.
"
Class {
	#name : 'DSCodeActionRecord',
	#superclass : 'DSAbstractEventRecord',
	#instVars : [
		'selectedString'
	],
	#category : 'DebuggingSpy-Records',
	#package : 'DebuggingSpy',
	#tag : 'Records'
}

{ #category : 'actions api' }
DSCodeActionRecord >> record: anEditor [

	selectedString := DSSpy recordSourceCode
		                  ifTrue: [ anEditor recordSelectedString ]
		                  ifFalse: [ DSSpy recordSourceCodeDisabledErrorMessage ].

	super record: anEditor
]

{ #category : 'accessing' }
DSCodeActionRecord >> selectedString [

	^ selectedString
]

{ #category : 'accessing' }
DSCodeActionRecord >> selectedString: anObject [

	selectedString := anObject
]
