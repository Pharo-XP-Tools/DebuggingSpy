"
I record when a method is removed.
"
Class {
	#name : 'DSMethodRemovedRecord',
	#superclass : 'DSMethodEventRecord',
	#category : 'DebuggingSpy-Records',
	#package : 'DebuggingSpy',
	#tag : 'Records'
}

{ #category : 'accessing' }
DSMethodRemovedRecord >> eventName [

	^ 'Method removed'
]
