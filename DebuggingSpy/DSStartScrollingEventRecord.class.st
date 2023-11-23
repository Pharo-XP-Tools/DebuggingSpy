"
I record when scrolling by dragging a slider stops.
"
Class {
	#name : 'DSStartScrollingEventRecord',
	#superclass : 'DSScrollEventRecord',
	#category : 'DebuggingSpy-Records',
	#package : 'DebuggingSpy',
	#tag : 'Records'
}

{ #category : 'accessing' }
DSStartScrollingEventRecord >> eventName [
	^'Scroll start'
]
