"
I record the installation or the modification of halt in the source code.
"
Class {
	#name : 'DSHaltChangeRecord',
	#superclass : 'DSAbstractHaltRecord',
	#instVars : [
		'haltChange',
		'haltData'
	],
	#category : 'DebuggingSpy-Records',
	#package : 'DebuggingSpy',
	#tag : 'Records'
}

{ #category : 'adding' }
DSHaltChangeRecord class >> add [
	^#HALT_ADD
]

{ #category : 'adding' }
DSHaltChangeRecord class >> modify [
	^#HALT_MODIFY
]

{ #category : 'adding' }
DSHaltChangeRecord class >> remove [
	^#HALT_REMOVE
]

{ #category : 'accessing' }
DSHaltChangeRecord >> eventName [
	^haltChange, ' (', method, ')'
]

{ #category : 'accessing' }
DSHaltChangeRecord >> haltChange [

	^ haltChange
]

{ #category : 'accessing' }
DSHaltChangeRecord >> haltData [

	^ haltData
]

{ #category : 'accessing' }
DSHaltChangeRecord >> haltData: anObject [

	haltData := anObject
]

{ #category : 'accessing' }
DSHaltChangeRecord >> method: aMethodName [
	method := aMethodName
]

{ #category : 'actions api' }
DSHaltChangeRecord >> record: aSymbol [
	haltChange := aSymbol
	
]
