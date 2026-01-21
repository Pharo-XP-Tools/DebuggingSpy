"
I represent the starting point in time of the performing of an experimental task.
"
Class {
	#name : 'DSStartTaskRecord',
	#superclass : 'DSAbstractTaskRecord',
	#category : 'DebuggingSpy-Records',
	#package : 'DebuggingSpy',
	#tag : 'Records'
}

{ #category : 'accessing' }
DSStartTaskRecord >> eventName [
	^'Starting task'
]
