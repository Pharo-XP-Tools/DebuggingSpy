Extension { #name : #DSSpy }

{ #category : #'*DebuggingSpy-Deprecated' }
DSSpy class >> dateTimeString [
	^'[' , DateAndTime now asString , ']:'
]

{ #category : #'*DebuggingSpy-Deprecated' }
DSSpy class >> logInspectorTabChange: selectedTab [
	[ 
	|anArrayOfMorphs |
	anArrayOfMorphs :=  selectedTab label allMorphs.
	self
		log: (self printGLMStringMorphs: anArrayOfMorphs)
		key: #INSPECTOR_TAB_SELECTION ]
		on: Error
		do: [ self log: #ERROR key: #INSPECTOR_TAB_SELECTION ]
]

{ #category : #'*DebuggingSpy-Deprecated' }
DSSpy class >> printGLMStringMorphs: anArrayOfMorphs [
	| str |
	str := WriteStream on: String new.
	anArrayOfMorphs
		do: [ :m | 
			(m isKindOf: GLMStringBrick)
				ifTrue: [ str << m text asString.
					str << ' ' ] ].
	^ str contents
]

{ #category : #'*DebuggingSpy-Deprecated' }
DSSpy class >> printStringMorphs: anArrayOfMorphs [
	| str |
	str := WriteStream on: String new.
	anArrayOfMorphs
		do: [ :m | 
			((m isKindOf: StringMorph) and: [ m contents ~= '...' ])
				ifTrue: [ str << m contents asString.
					str << ' ' ] ].
	^ str contents
]

{ #category : #'*DebuggingSpy-Deprecated' }
DSSpy class >> windowName: win [
	|label|	
	label := [win labelString ] on: Error do:['window '].
	^label, ' (', win hash printString, ')'
]

{ #category : #'*DebuggingSpy-Deprecated' }
DSSpy class >> windowNameFromEvent: anEvent [
	|win|
	win := anEvent window.
	^self windowName: win
]
