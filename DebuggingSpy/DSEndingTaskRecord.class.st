"
I represent the ending point in time of an experimental task.
Tasks are object that should answer to `#name`, `#description` and `#answer`, all returning a string

"
Class {
	#name : #DSEndingTaskRecord,
	#superclass : #DSAbstractTaskRecord,
	#instVars : [
		'answer'
	],
	#category : #'DebuggingSpy-Records'
}

{ #category : #accessing }
DSEndingTaskRecord >> eventName [
	^'Ending task'
]

{ #category : #'actions api' }
DSEndingTaskRecord >> record: aTask [
	super record: aTask.
	answer := aTask answer
]
