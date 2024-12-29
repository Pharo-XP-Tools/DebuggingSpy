"
I record a PhexSurvey with its answer.
Only closed surveys (that is, with an answer to all its questions) should be recored.
"
Class {
	#name : 'DSSurveyRecord',
	#superclass : 'DSAbstractEventRecord',
	#instVars : [
		'survey'
	],
	#category : 'DebuggingSpy-Records',
	#package : 'DebuggingSpy',
	#tag : 'Records'
}

{ #category : 'accessing' }
DSSurveyRecord >> answer [
	^survey answer
]


{ #category : 'accessing' }
DSSurveyRecord >> collectAnswers [
	^survey collectAnswers
]

{ #category : #'as yet unclassified' }
DSSurveyRecord >> collectAnswersFromQuestions [
	^survey collectAnswersFromQuestions 
]

{ #category : #accessing }
DSSurveyRecord >> description [

	^ survey title
]

{ #category : 'accessing' }
DSSurveyRecord >> eventName [
	^'Survey closed'
]

{ #category : 'printing' }
DSSurveyRecord >> printOn: aStream [
	super printOn: aStream.
	survey ifNil:[^self].
	aStream space.
	aStream << ':'.
	aStream space.
	aStream << survey title
]

{ #category : 'accessing' }
DSSurveyRecord >> record: aSurvey [
	survey := aSurvey
]

{ #category : 'accessing' }
DSSurveyRecord >> survey [
	^survey
]
