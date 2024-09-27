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
	^'Task success ', self success asString
]

{ #category : #accessing }
DSTaskSuccessRecord >> record: anArray [
	super record: anArray first.
	success := anArray second
]

{ #category : #accessing }
DSTaskSuccessRecord >> success [

	^ success ifNil: [ success := false ] ifNotNil: [ success ]
]
