"
I record a PhexSurvey with its answer.
Only closed surveys (that is, with an answer to all its questions) should be recored.
"
Class {
	#name : #DSSurveyRecord,
	#superclass : #DSAbstractEventRecord,
	#instVars : [
		'survey'
	],
	#category : #'DebuggingSpy-Records'
}

{ #category : #accessing }
DSSurveyRecord >> answer [
	^survey answer
]

{ #category : #accessing }
DSSurveyRecord >> description [

	^ survey title
]

{ #category : #accessing }
DSSurveyRecord >> eventName [
	^'Survey closed'
]

{ #category : #accessing }
DSSurveyRecord >> record: aSurvey [
	survey := aSurvey
]

{ #category : #accessing }
DSSurveyRecord >> survey [
	^survey
]