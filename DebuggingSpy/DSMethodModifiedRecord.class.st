"
I record when a method is modified.
"
Class {
	#name : 'DSMethodModifiedRecord',
	#superclass : 'DSMethodEventRecord',
	#category : 'DebuggingSpy-Records',
	#package : 'DebuggingSpy',
	#tag : 'Records'
}

{ #category : 'accessing' }
DSMethodModifiedRecord >> eventName [

	^ 'Method modified'
]
