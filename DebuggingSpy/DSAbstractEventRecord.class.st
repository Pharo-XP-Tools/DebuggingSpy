"
I represent a recorded event, that happened from a tool.
"
Class {
	#name : #DSAbstractEventRecord,
	#superclass : #Object,
	#instVars : [
		'dateTime',
		'windowId'
	],
	#category : #'DebuggingSpy-Records'
}

{ #category : #'instance creation' }
DSAbstractEventRecord class >> for: anObject [

	| rec |
	rec := self new record: anObject.
	DSRecordRegistry current addRecord: rec.
	^ rec
]

{ #category : #printing }
DSAbstractEventRecord class >> printStringMorphs: anArrayOfMorphs [

	| str |
	str := WriteStream on: String new.
	anArrayOfMorphs do: [ :m | 
		((m isKindOf: StringMorph) and: [ m contents ~= '...' ]) ifTrue: [ 
			str << m contents asString.
			m == anArrayOfMorphs last ifFalse: [ str << ' ' ] ] ].
	^ str contents
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

{ #category : #printing }
DSAbstractEventRecord >> printOn: aStream [
	aStream << self eventName
]

{ #category : #'actions api' }
DSAbstractEventRecord >> record: aWindow [
	self assert: (aWindow isKindOf: SystemWindow).
	windowId := aWindow hash
]

{ #category : #accessing }
DSAbstractEventRecord >> windowId [

	^ windowId
]

{ #category : #accessing }
DSAbstractEventRecord >> windowId: anObject [

	windowId := anObject
]
