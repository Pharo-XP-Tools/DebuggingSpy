Extension { #name : 'Halt' }

{ #category : '*DebuggingSpy' }
Halt class >> signal [

	DSSpy recordingSession ifTrue: [
			[
				| sender |
				sender := thisContext sender sender sender sender sender.
				DSHaltHitRecord for: {
						sender sourceNodeExecuted.
						#halt } ]
				on: Error
				do: [ :err | DSSpy log: #ERROR key: #HALT_HIT ] ].
	super signal
]

{ #category : '*DebuggingSpy' }
Halt class >> signal: s [

	DSSpy recordingSession ifTrue: [
			[
				| sender |
				sender := thisContext sender sender sender sender sender.
				DSHaltHitRecord for: {
						sender sourceNodeExecuted.
						#now: } ]
				on: Error
				do: [ DSSpy log: #ERROR key: #HALT_HIT ] ].
	super signal: s
]

{ #category : '*DebuggingSpy' }
Halt class >> signalIn: ctx [

	DSSpy recordingSession ifTrue: [
			[
				| sender |
				sender := thisContext sender sender sender sender sender sender sender sender sender.
				ctx selector = #once: ifFalse: [ sender := sender sender ].
				DSHaltHitRecord for: {
						sender sourceNodeExecuted.
						ctx selector } ]
				on: Error
				do: [ DSSpy log: #ERROR key: #HALT_HIT ] ].
			
	^ super signalIn: ctx
]
