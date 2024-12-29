"
I record when a method is removed.
"
Class {
	#name : #DSMethodRemovedRecord,
	#superclass : #DSMethodEventRecord,
	#category : #'DebuggingSpy-Records'
}

{ #category : #accessing }
DSMethodRemovedRecord >> eventName [

	^ 'Method removed'
]
