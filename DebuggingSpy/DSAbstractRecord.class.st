"
I represent a recorded event, that happened from a tool.
"
Class {
	#name : #DSAbstractRecord,
	#superclass : #Object,
	#instVars : [
		'dateTime'
	],
	#category : #'DebuggingSpy-Records'
}

{ #category : #comparing }
DSAbstractRecord >> < aDSAbstractRecord [
	^self dateTime < aDSAbstractRecord dateTime
]

{ #category : #comparing }
DSAbstractRecord >> <= aDSAbstractRecord [
	^self dateTime <= aDSAbstractRecord dateTime
]

{ #category : #comparing }
DSAbstractRecord >> > aDSAbstractRecord [
	^self dateTime > aDSAbstractRecord dateTime
]

{ #category : #comparing }
DSAbstractRecord >> >= aDSAbstractRecord [
	^self dateTime >= aDSAbstractRecord dateTime
]

{ #category : #accessing }
DSAbstractRecord >> dateTime [

	^ dateTime
]

{ #category : #initialization }
DSAbstractRecord >> initialize [
	dateTime := DateAndTime now
]
