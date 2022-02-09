"
I represent the result of an automatic evaluation of a task success.
true = success.
false = failure.
This boolean is stored into the success inst var.
"
Class {
	#name : #DSTaskSuccessRecord,
	#superclass : #DSAbstractTaskRecord,
	#instVars : [
		'success'
	],
	#category : #'DebuggingSpy-Records'
}

{ #category : #accessing }
DSTaskSuccessRecord >> eventName [
	^'Task success ', self success
]

{ #category : #accessing }
DSTaskSuccessRecord >> record: anArray [
	super record: anArray first.
	success := anArray second
]

{ #category : #accessing }
DSTaskSuccessRecord >> success [
	 ^success ifNil:[success := false]
]
