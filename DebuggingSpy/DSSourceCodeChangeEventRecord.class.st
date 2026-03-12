"
I record a change in source code:
- I know the name and class of the method changed
- I know the old source code
- I know the new source code
"
Class {
	#name : 'DSSourceCodeChangeEventRecord',
	#superclass : 'DSMethodEventRecord',
	#instVars : [
		'oldSource',
		'newSource'
	],
	#category : 'DebuggingSpy-Records',
	#package : 'DebuggingSpy',
	#tag : 'Records'
}

{ #category : 'examples' }
DSSourceCodeChangeEventRecord class >> example [
	"Returns an exemple of object for this class."

	| method |
	method := self >> #eventName.

	^ self new
		  record: {
				  method.
				  'old source code'.
				  'new source code' };
		  windowId: MorphicNativeWindow basicNew hash;
		  yourself
]

{ #category : 'accessing' }
DSSourceCodeChangeEventRecord >> eventName [
	^'Source code modification'
]

{ #category : 'accessing' }
DSSourceCodeChangeEventRecord >> newSource [

	^ newSource
]

{ #category : 'accessing' }
DSSourceCodeChangeEventRecord >> oldSource [

	^ oldSource
]

{ #category : 'actions api' }
DSSourceCodeChangeEventRecord >> record: anArray [
	super record: anArray first.
	oldSource := anArray second.
	newSource := anArray third
]
