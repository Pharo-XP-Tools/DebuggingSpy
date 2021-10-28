"
I record when scrolling by dragging a slider stops.
"
Class {
	#name : #DSStopScrollingEventRecord,
	#superclass : #DSScrollEventRecord,
	#category : #'DebuggingSpy-Records'
}

{ #category : #accessing }
DSStopScrollingEventRecord >> eventName [
	^'Scroll stop'
]
