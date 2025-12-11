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

{ #category : 'accessing' }
DSCodeActionRecord class >> link [
	^ MetaLink new
		metaObject: self;
		selector: #for:;
		arguments: #(receiver);
		control: #before
]

{ #category : 'actions api' }
DSCodeActionRecord >> record: anObject [

	selectedString := DSSpy recordSourceCode
		                  ifTrue: [ anObject recordSelectedString ]
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
