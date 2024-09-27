Class {
	#name : #DSWindowAnnotation,
	#superclass : #Object,
	#instVars : [
		'index',
		'annotation'
	],
	#category : #'DebuggingSpy-Records-Extensions'
}

{ #category : #accessing }
DSWindowAnnotation >> annotation [

	^ annotation ifNil:[annotation := '']
]

{ #category : #accessing }
DSWindowAnnotation >> annotation: anObject [

	annotation := anObject
]

{ #category : #accessing }
DSWindowAnnotation >> index [

	^ index  ifNil:[index := 0]
]

{ #category : #accessing }
DSWindowAnnotation >> index: anObject [

	index := anObject
]

{ #category : #'as yet unclassified' }
DSWindowAnnotation >> intialize [
	annotation := String new.
	index := 0
]
