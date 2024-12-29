"
I represent the ending point in time of an experimental task.
Tasks are object that should answer to `#name`, `#description` and `#answer`, all returning a string

"
Class {
	#name : 'DSEndingTaskRecord',
	#superclass : 'DSAbstractTaskRecord',
	#category : 'DebuggingSpy-Records',
	#package : 'DebuggingSpy',
	#tag : 'Records'
}

{ #category : 'accessing' }
DSEndingTaskRecord >> answer [
	^ task answer
]

{ #category : 'accessing' }
DSEndingTaskRecord >> eventName [
	^'Ending task'
]
