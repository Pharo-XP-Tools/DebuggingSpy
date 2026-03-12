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

{ #category : 'examples' }
DSCodeActionRecord class >> example [
	"Returns an exemple of object for this class."

	^ self new
		  record: (RubSmalltalkEditor new
				   textArea: RubEditingArea new;
				   yourself);
		  windowId: MorphicNativeWindow basicNew hash;
		  yourself
]

{ #category : 'actions api' }
DSCodeActionRecord >> record: anEditor [

	selectedString := DSSpy recordSourceCode
		                  ifTrue: [ anEditor recordSelectedString ]
		                  ifFalse: [ 
		                  DSSpy recordSourceCodeDisabledErrorMessage ]
]

{ #category : 'accessing' }
DSCodeActionRecord >> selectedString [

	^ selectedString
]

{ #category : 'accessing' }
DSCodeActionRecord >> selectedString: anObject [

	selectedString := anObject
]
