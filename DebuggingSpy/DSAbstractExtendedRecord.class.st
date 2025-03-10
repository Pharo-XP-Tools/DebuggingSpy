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

{ #category : 'accessing' }
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

{ #category : 'accessing' }
DSAbstractExtendedRecord >> windowId [

	^ sourceRecord windowId
]
