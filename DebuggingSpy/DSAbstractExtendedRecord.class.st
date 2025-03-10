Class {
	#name : 'DSAbstractExtendedRecord',
	#superclass : 'DSAbstractEventRecord',
	#instVars : [
		'sourceRecord'
	],
	#category : 'DebuggingSpy-Records-Extensions',
	#package : 'DebuggingSpy',
	#tag : 'Records-Extensions'
}

{ #category : 'instance creation' }
DSAbstractExtendedRecord class >> for: anObject [

	^ self new
		  record: anObject;
		  yourself
]

{ #category : 'actions api' }
DSAbstractExtendedRecord >> dateTime [

	^ sourceRecord dateTime
]

{ #category : 'accessing' }
DSAbstractExtendedRecord >> realRecord [

	^ sourceRecord
]

{ #category : 'actions api' }
DSAbstractExtendedRecord >> record: aSourceRecord [
	sourceRecord := aSourceRecord 
]

{ #category : 'actions api' }
DSAbstractExtendedRecord >> windowId [

	^ sourceRecord windowId
]
