Class {
	#name : 'DSWindowAnnotation',
	#superclass : 'Object',
	#instVars : [
		'index',
		'annotation'
	],
	#category : 'DebuggingSpy-Records-Extensions',
	#package : 'DebuggingSpy',
	#tag : 'Records-Extensions'
}

{ #category : 'accessing' }
DSWindowAnnotation >> annotation [

	^ annotation ifNil:[annotation := '']
]

{ #category : 'accessing' }
DSWindowAnnotation >> annotation: anObject [

	annotation := anObject
]

{ #category : 'accessing' }
DSWindowAnnotation >> index [

	^ index  ifNil:[index := 0]
]

{ #category : 'accessing' }
DSWindowAnnotation >> index: anObject [

	index := anObject
]

{ #category : 'initialization' }
DSWindowAnnotation >> initialize [
	annotation := String new.
	index := 0
]
