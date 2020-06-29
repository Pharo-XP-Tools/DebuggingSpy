Extension { #name : #BreakpointNotification }

{ #category : #'*DebuggingSpy' }
BreakpointNotification >> logBreakpointEventOn: aLogger [
	| key log |
	key := self breakpoint key , '_' , self logKey.
	log := WriteStream on: String new.
	(self nodes collect: [ :n | n methodNode method method name ]) asSet
		do: [ :str | 
			log << str.
			log << '.' ].
	aLogger log: log key: key
]
