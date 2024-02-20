Class {
	#name : #DSBreakpointRecord,
	#superclass : #DSAbstractExtendedRecord,
	#category : #'DebuggingSpy-Records-Extensions'
}

{ #category : #'as yet unclassified' }
DSBreakpointRecord >> canOpenDebuggers [
	^sourceRecord canOpenDebuggers
]

{ #category : #'as yet unclassified' }
DSBreakpointRecord >> eventName [
	^sourceRecord eventName
]

{ #category : #'as yet unclassified' }
DSBreakpointRecord >> objectCentric [
	^sourceRecord objectCentric
]

{ #category : #'as yet unclassified' }
DSBreakpointRecord >> once [
	^sourceRecord once
]

{ #category : #'as yet unclassified' }
DSBreakpointRecord >> printTargetInstance: anObject [
	^sourceRecord printTargetInstance: anObject
]

{ #category : #'as yet unclassified' }
DSBreakpointRecord >> target [
	^sourceRecord target
]
