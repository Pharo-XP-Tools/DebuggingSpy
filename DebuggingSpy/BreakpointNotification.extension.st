Extension { #name : #BreakpointNotification }

{ #category : #'*DebuggingSpy' }
BreakpointNotification >> logBreakpointEventOn: aLogger [
	| key log |
	key := self breakpoint key , '_' , self logKey.
	log := WriteStream on: String new.
	(self nodes
		collect: [ :n | 
			| selector class |
			selector := n methodNode selector.
			class := n methodNode methodClass.
			class name , '>>' , selector ]) asSet
		do: [ :str | 
			log << str.
			log << '.' ].
	aLogger log: log contents key: key
]
