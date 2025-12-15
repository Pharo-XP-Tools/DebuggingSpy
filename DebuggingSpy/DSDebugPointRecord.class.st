"
I represent a debugPoint recorded event.
"
Class {
	#name : 'DSDebugPointRecord',
	#superclass : 'DSAbstractExtendedRecord',
	#category : 'DebuggingSpy-Records-Extensions',
	#package : 'DebuggingSpy',
	#tag : 'Records-Extensions'
}

{ #category : 'instance creation' }
DSDebugPointRecord class >> debugpointadded: event [ 
	^ self subclassResponsibility
]

{ #category : 'instance creation' }
DSDebugPointRecord class >> debugpointhit: event [ 
	^ self subclassResponsibility
]

{ #category : 'instance creation' }
DSDebugPointRecord class >> debugpointremoved: event [ 
	^ self subclassResponsibility
]

{ #category : 'testing' }
DSDebugPointRecord >> canOpenDebuggers [

	^ sourceRecord canOpenDebuggers
]

{ #category : 'accessing' }
DSDebugPointRecord >> debugPointHash [

	^ sourceRecord debugPointHash
]

{ #category : 'accessing' }
DSDebugPointRecord >> eventName [

	^ sourceRecord eventName
]

{ #category : 'accessing' }
DSDebugPointRecord >> eventSymbol [
	^self subclassResponsibility
]

{ #category : 'accessing' }
DSDebugPointRecord >> objectCentric [

	^ sourceRecord objectCentric
]

{ #category : 'accessing' }
DSDebugPointRecord >> once [

	^ sourceRecord once
]

{ #category : 'printing' }
DSDebugPointRecord >> printContextAndNode [
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
DSDebugPointRecord >> printTargetInstance: anObject [
	^sourceRecord printTargetInstance: anObject
]

{ #category : 'accessing' }
DSDebugPointRecord >> submethodTargets [

	^ self subclassResponsibility
]

{ #category : 'accessing' }
DSDebugPointRecord >> target [

	^ sourceRecord target
]

{ #category : 'accessing' }
DSDebugPointRecord >> targetClassOrMethod [

	^ self subclassResponsibility
]
