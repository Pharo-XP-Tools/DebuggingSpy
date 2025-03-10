Class {
	#name : 'DSStepRecord',
	#superclass : 'DSAbstractExtendedRecord',
	#category : 'DebuggingSpy-Records-Extensions',
	#package : 'DebuggingSpy',
	#tag : 'Records-Extensions'
}

{ #category : 'as yet unclassified' }
DSStepRecord class >> for: anEvent [

	| step |
	step := self new.
	step become: anEvent.
	anEvent record: step.
	^ anEvent
]

{ #category : 'as yet unclassified' }
DSStepRecord class >> into: aDSDebuggerActionRecord [

	^ DSIntoRecord for: aDSDebuggerActionRecord
]

{ #category : 'as yet unclassified' }
DSStepRecord class >> over: aDSDebuggerActionRecord [

	^ DSOverRecord for: aDSDebuggerActionRecord
]

{ #category : 'as yet unclassified' }
DSStepRecord class >> proceed: aDSDebuggerActionRecord [

	^ DSProceedRecord for: aDSDebuggerActionRecord
]

{ #category : 'as yet unclassified' }
DSStepRecord class >> restart: aDSDebuggerActionRecord [

	^ DSRestartRecord for: aDSDebuggerActionRecord
]

{ #category : 'as yet unclassified' }
DSStepRecord class >> return: aDSDebuggerActionRecord [

	^ DSReturnRecord for: aDSDebuggerActionRecord
]

{ #category : 'as yet unclassified' }
DSStepRecord class >> runto: aDSDebuggerActionRecord [

	^ DSRunToRecord for: aDSDebuggerActionRecord
]

{ #category : 'as yet unclassified' }
DSStepRecord class >> sindarinStep: aDSDebuggerActionRecord [

	^ DSSindarinStepRecord for: aDSDebuggerActionRecord
]

{ #category : 'as yet unclassified' }
DSStepRecord class >> through: aDSDebuggerActionRecord [

	^ DSThroughRecord for: aDSDebuggerActionRecord
]

{ #category : 'accessing' }
DSStepRecord >> context [
	^sourceRecord context
]

{ #category : 'accessing' }
DSStepRecord >> eventName [
	^ sourceRecord eventName
]

{ #category : 'as yet unclassified' }
DSStepRecord >> eventSymbol [
	^'V'
]

{ #category : 'accessing' }
DSStepRecord >> node [
	^sourceRecord node
]

{ #category : 'printing' }
DSStepRecord >> printContextAndNode [
	^sourceRecord printContextAndNode 
]

{ #category : 'accessing' }
DSStepRecord >> receiver [
	^sourceRecord receiver
]

{ #category : 'accessing' }
DSStepRecord >> receiverClass [
	^sourceRecord receiverClass
]
