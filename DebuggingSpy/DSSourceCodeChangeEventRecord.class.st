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

{ #category : 'instance creation' }
DSSourceCodeChangeEventRecord class >> added: aMethod [

	^ (self for: aMethod)
		  eventName: 'Method added';
		  yourself
]

{ #category : 'instance creation' }
DSSourceCodeChangeEventRecord class >> modified: aMethod [

	^ (self for: aMethod)
		  eventName: 'Method modified';
		  yourself
]

{ #category : 'instance creation' }
DSSourceCodeChangeEventRecord class >> removed: aMethod [

	^ (self for: aMethod)
		  eventName: 'Method removed';
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
