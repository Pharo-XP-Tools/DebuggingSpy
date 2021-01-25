"
I represent a recorded event, that happened from a tool.
"
Class {
	#name : #DSAbstractEventRecord,
	#superclass : #Object,
	#instVars : [
		'dateTime'
	],
	#category : #'DebuggingSpy-Records'
}

{ #category : #'instance creation' }
DSAbstractEventRecord class >> for: anObject [
	^self new record: anObject 
]

{ #category : #comparing }
DSAbstractEventRecord >> < aDSAbstractRecord [
	^self dateTime < aDSAbstractRecord dateTime
]

{ #category : #comparing }
DSAbstractEventRecord >> <= aDSAbstractRecord [
	^self dateTime <= aDSAbstractRecord dateTime
]

{ #category : #comparing }
DSAbstractEventRecord >> > aDSAbstractRecord [
	^self dateTime > aDSAbstractRecord dateTime
]

{ #category : #comparing }
DSAbstractEventRecord >> >= aDSAbstractRecord [
	^self dateTime >= aDSAbstractRecord dateTime
]

{ #category : #accessing }
DSAbstractEventRecord >> dateTime [

	^ dateTime
]

{ #category : #accessing }
DSAbstractEventRecord >> dateTime: anObject [

	dateTime := anObject
]

{ #category : #accessing }
DSAbstractEventRecord >> eventName [
	^self subclassResponsibility 
]

{ #category : #initialization }
DSAbstractEventRecord >> initialize [
	dateTime := DateAndTime now
]

{ #category : #'actions api' }
DSAbstractEventRecord >> record: anObject [ 
	self subclassResponsibility 
]
