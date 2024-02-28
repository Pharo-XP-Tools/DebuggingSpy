Class {
	#name : #DSBreakpointRecord,
	#superclass : #DSAbstractExtendedRecord,
	#category : #'DebuggingSpy-Records-Extensions'
}

{ #category : #accessing }
DSBreakpointRecord >> breakpointHash [

	^ sourceRecord breakpointHash
]

{ #category : #testing }
DSBreakpointRecord >> canOpenDebuggers [
	^sourceRecord canOpenDebuggers
]

{ #category : #accessing }
DSBreakpointRecord >> eventName [
	^sourceRecord eventName
]

{ #category : #accessing }
DSBreakpointRecord >> objectCentric [
	^sourceRecord objectCentric
]

{ #category : #accessing }
DSBreakpointRecord >> once [
	^sourceRecord once
]

{ #category : #printing }
DSBreakpointRecord >> printTargetInstance: anObject [
	^sourceRecord printTargetInstance: anObject
]

{ #category : #accessing }
DSBreakpointRecord >> submethodTargets [
	^self subclassResponsibility 
]

{ #category : #accessing }
DSBreakpointRecord >> target [
	^sourceRecord target
]

{ #category : #accessing }
DSBreakpointRecord >> targetClassOrMethod [
	^self subclassResponsibility 
]
