"
I record user debugging actions applied on code, such as debug it, doit, print it.
I store the code string on which the user applied that action.
"
Class {
	#name : #DSCodeActionRecord,
	#superclass : #DSAbstractEventRecord,
	#instVars : [
		'selectedString'
	],
	#category : #'DebuggingSpy-Records'
}

{ #category : #'actions api' }
DSCodeActionRecord >> record: aCodeString [

	selectedString := DSSpy recordSourceCode
		                  ifTrue: [ aCodeString ]
		                  ifFalse: [ 
		                  DSSpy recordSourceCodeDisabledErrorMessage ]
]

{ #category : #accessing }
DSCodeActionRecord >> selectedString [

	^ selectedString
]

{ #category : #accessing }
DSCodeActionRecord >> selectedString: anObject [

	selectedString := anObject
]
