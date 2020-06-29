Extension { #name : #Breakpoint }

{ #category : #'*DebuggingSpy' }
Breakpoint >> key [
	| str |
	str := WriteStream on: String new.
	self isObjectCentric
		ifTrue: [ str << 'OC' ].
	str << self logKey.
	^ str contents
]

{ #category : #'*DebuggingSpy' }
Breakpoint >> logKey [
	^'BREAKPOINT'
]
