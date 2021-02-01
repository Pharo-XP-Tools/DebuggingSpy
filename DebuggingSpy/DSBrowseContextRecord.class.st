"
I record printed representation of browsed contexts in the debugger:
- the receiver
- the selector
"
Class {
	#name : #DSBrowseContextRecord,
	#superclass : #DSDebuggerRecord,
	#instVars : [
		'receiver',
		'selector'
	],
	#category : #'DebuggingSpy-Records'
}

{ #category : #accessing }
DSBrowseContextRecord >> eventName [
	^'Browse context'
]

{ #category : #accessing }
DSBrowseContextRecord >> receiver [

	^ receiver
]

{ #category : #accessing }
DSBrowseContextRecord >> receiver: anObject [

	receiver := anObject
]

{ #category : #'actions api' }
DSBrowseContextRecord >> record: aContextAndWindow [ 
	|ctx|
	super record: aContextAndWindow.
	ctx := aContextAndWindow first.
	receiver := ctx receiver printString.
	selector := ctx selector
]

{ #category : #accessing }
DSBrowseContextRecord >> selector [

	^ selector
]

{ #category : #accessing }
DSBrowseContextRecord >> selector: anObject [

	selector := anObject
]
