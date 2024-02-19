Class {
	#name : #DSStepRecord,
	#superclass : #DSAbstractExtendedRecord,
	#category : #'DebuggingSpy-Records-Extensions'
}

{ #category : #'as yet unclassified' }
DSStepRecord class >> into: aDSDebuggerActionRecord [

	^ DSIntoRecord for: aDSDebuggerActionRecord
]

{ #category : #'as yet unclassified' }
DSStepRecord class >> over: aDSDebuggerActionRecord [

	^ DSOverRecord for: aDSDebuggerActionRecord
]

{ #category : #'as yet unclassified' }
DSStepRecord class >> proceed: aDSDebuggerActionRecord [

	^ DSProceedRecord for: aDSDebuggerActionRecord
]

{ #category : #'as yet unclassified' }
DSStepRecord class >> restart: aDSDebuggerActionRecord [

	^ DSRestartRecord for: aDSDebuggerActionRecord
]

{ #category : #'as yet unclassified' }
DSStepRecord class >> return: aDSDebuggerActionRecord [

	^ DSReturnRecord for: aDSDebuggerActionRecord
]

{ #category : #'as yet unclassified' }
DSStepRecord class >> runto: aDSDebuggerActionRecord [

	^ DSRunToRecord for: aDSDebuggerActionRecord
]

{ #category : #'as yet unclassified' }
DSStepRecord class >> through: aDSDebuggerActionRecord [

	^ DSThroughRecord for: aDSDebuggerActionRecord
]

{ #category : #accessing }
DSStepRecord >> contextName [
	^sourceRecord contextName
]

{ #category : #accessing }
DSStepRecord >> eventName [
	^ sourceRecord eventName
]

{ #category : #accessing }
DSStepRecord >> sourceNodeClass [
	^sourceRecord sourceNodeClass
]

{ #category : #accessing }
DSStepRecord >> sourceNodeCode [
	^sourceRecord sourceNodeCode
]
