Class {
	#name : 'DSBreakpointRecord',
	#superclass : 'DSAbstractExtendedRecord',
	#category : 'DebuggingSpy-Records-Extensions',
	#package : 'DebuggingSpy',
	#tag : 'Records-Extensions'
}

{ #category : 'accessing' }
DSBreakpointRecord >> breakpointHash [

	^ sourceRecord breakpointHash
]

{ #category : 'testing' }
DSBreakpointRecord >> canOpenDebuggers [

	^ sourceRecord canOpenDebuggers
]

{ #category : 'accessing' }
DSBreakpointRecord >> eventName [

	^ sourceRecord eventName
]

{ #category : 'as yet unclassified' }
DSBreakpointRecord >> eventSymbol [
	^self subclassResponsibility
]

{ #category : 'accessing' }
DSBreakpointRecord >> objectCentric [

	^ sourceRecord objectCentric
]

{ #category : 'accessing' }
DSBreakpointRecord >> once [

	^ sourceRecord once
]

{ #category : 'printing' }
DSBreakpointRecord >> printContextAndNode [
	self flag: 'This cannot work with the DSVariableBreakpointRecord subclass: is this even called?'.
	^ String streamContents: [ :s |
		  | nodeStream peek |
		  s << '['.
		  s << self eventName.
		  s << ']'.
		  s space.
		  s << self method]
]

{ #category : 'printing' }
DSBreakpointRecord >> printTargetInstance: anObject [
	^sourceRecord printTargetInstance: anObject
]

{ #category : 'accessing' }
DSBreakpointRecord >> submethodTargets [

	^ self subclassResponsibility
]

{ #category : 'accessing' }
DSBreakpointRecord >> target [

	^ sourceRecord target
]

{ #category : 'accessing' }
DSBreakpointRecord >> targetClassOrMethod [

	^ self subclassResponsibility
]
