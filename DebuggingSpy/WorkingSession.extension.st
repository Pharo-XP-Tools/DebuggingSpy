Extension { #name : 'WorkingSession' }

{ #category : '*DebuggingSpy' }
WorkingSession >> id [

	^ properties at: #id ifAbsentPut: [ UUID new ]
]
