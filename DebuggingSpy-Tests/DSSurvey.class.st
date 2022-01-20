"
I simulate a survey that can be managed through DSSpy.
"
Class {
	#name : #DSSurvey,
	#superclass : #Object,
	#instVars : [
		'answer',
		'uuid'
	],
	#category : #'DebuggingSpy-Tests'
}

{ #category : #accessing }
DSSurvey class >> dsSurveyDescription [

	^ 'DS test survey'
]

{ #category : #accessing }
DSSurvey >> answer [ 	
	^answer
]

{ #category : #accessing }
DSSurvey >> answer: anObject [

	answer := anObject
]

{ #category : #accessing }
DSSurvey >> description [ 	
	^self class dsSurveyDescription
]

{ #category : #initialization }
DSSurvey >> initialize [

	super initialize.
	answer := self class dsSurveyDescription
]

{ #category : #accessing }
DSSurvey >> title [
	^self description 
]

{ #category : #accessing }
DSSurvey >> uuid [

	^ uuid ifNil: [ uuid := UUID new ]
]
