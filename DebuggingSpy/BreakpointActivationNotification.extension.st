Extension { #name : #BreakpointActivationNotification }

{ #category : #'*DebuggingSpy' }
BreakpointActivationNotification >> logKey [
	^ activated
		ifTrue: [ 'ACTIVATED' ]
		ifFalse: [ 'DEACTIVATED' ]
]
