Class {
	#name : #DSHaltReport,
	#superclass : #DSExceptionReport,
	#category : #'DebuggingSpy-Records-Extensions'
}

{ #category : #printing }
DSHaltReport >> printOn: aStream [

	super printOn: aStream.
	aStream space.
	aStream << 'halts'
]
