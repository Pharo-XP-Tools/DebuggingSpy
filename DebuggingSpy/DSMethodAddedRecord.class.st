"
I record when a method is added.
"
Class {
	#name : 'DSMethodAddedRecord',
	#superclass : 'DSMethodEventRecord',
	#category : 'DebuggingSpy-Records',
	#package : 'DebuggingSpy',
	#tag : 'Records'
}

{ #category : 'accessing' }
DSMethodAddedRecord >> eventName [
	^'Method added'
]
