"
I record the installation or the modification of halt in the source code.
"
Class {
	#name : #DSHaltChangeRecord,
	#superclass : #DSAbstractHaltRecord,
	#category : #'DebuggingSpy-Records'
}

{ #category : #accessing }
DSHaltChangeRecord >> eventName [
	^'Halt change'
]
