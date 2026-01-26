Class {
	#name : 'DSHaltReport',
	#superclass : 'DSExceptionReport',
	#category : 'DebuggingSpy-Records',
	#package : 'DebuggingSpy',
	#tag : 'Records'
}

{ #category : 'printing' }
DSHaltReport >> printOn: aStream [

	super printOn: aStream.
	aStream space.
	aStream << 'halts'
]
