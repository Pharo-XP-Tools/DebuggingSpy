"
I represent a recorded event, that happened from a tool.
"
Class {
	#name : 'DSAbstractEventRecord',
	#superclass : 'Object',
	#instVars : [
		'dateTime',
		'windowId',
		'uuid'
	],
	#category : 'DebuggingSpy-Records',
	#package : 'DebuggingSpy',
	#tag : 'Records'
}

{ #category : 'instance creation' }
DSAbstractEventRecord class >> for: anObject [

	| rec |
	rec := self new record: anObject.
	DSRecordRegistry current addRecord: rec.
	^ rec
]

{ #category : 'accessing' }
DSAbstractEventRecord class >> link [
		
	^ DSMetaLink new
		  metaObject: self;
		  selector: #for:;
		  arguments: #( receiver );
		  control: #before
]

{ #category : 'comparing' }
DSAbstractEventRecord >> < aDSAbstractRecord [
	^self dateTime < aDSAbstractRecord dateTime
]

{ #category : 'comparing' }
DSAbstractEventRecord >> <= aDSAbstractRecord [
	^self dateTime <= aDSAbstractRecord dateTime
]

{ #category : 'comparing' }
DSAbstractEventRecord >> > aDSAbstractRecord [
	^self dateTime > aDSAbstractRecord dateTime
]

{ #category : 'comparing' }
DSAbstractEventRecord >> >= aDSAbstractRecord [
	^self dateTime >= aDSAbstractRecord dateTime
]

{ #category : 'testing' }
DSAbstractEventRecord >> canOpenDebuggers [

	^ true
]

{ #category : 'accessing' }
DSAbstractEventRecord >> dateTime [

	^ dateTime
]

{ #category : 'accessing' }
DSAbstractEventRecord >> dateTime: anObject [

	dateTime := anObject
]

{ #category : 'accessing' }
DSAbstractEventRecord >> eventName [
	^self subclassResponsibility 
]

{ #category : 'initialization' }
DSAbstractEventRecord >> initialize [
	dateTime := DateAndTime now.
	uuid := UUID new
]

{ #category : 'printing' }
DSAbstractEventRecord >> printContext [

	^ self context
]

{ #category : 'printing' }
DSAbstractEventRecord >> printOn: aStream [
	aStream << self eventName
]

{ #category : 'accessing' }
DSAbstractEventRecord >> realRecord [
	^self
]

{ #category : 'actions api' }
DSAbstractEventRecord >> record: aWindow [

	self windowId: aWindow identityHash.
]

{ #category : 'accessing' }
DSAbstractEventRecord >> uuid [

	^ uuid
]

{ #category : 'accessing' }
DSAbstractEventRecord >> windowId [

	^ windowId
]

{ #category : 'accessing' }
DSAbstractEventRecord >> windowId: aWindowId [

	windowId := aWindowId = nil identityHash ifTrue: [ nil ] ifFalse: [ aWindowId ]
]

{ #category : 'accessing' }
DSAbstractEventRecord >> windowType [
	^'Unknown Window'
]
