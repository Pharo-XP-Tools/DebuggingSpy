"
I am an event record class to test ds records mechanics.
"
Class {
	#name : #DSTestRecord,
	#superclass : #DSAbstractEventRecord,
	#category : #'DebuggingSpy-Tests'
}

{ #category : #accessing }
DSTestRecord >> eventName [
	^'test'
]
