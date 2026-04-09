Extension { #name : 'StInspectorPresenter' }

{ #category : '*DebuggingSpy-Browser' }
StInspectorPresenter class >> windowColor [

	<DSWindowColor>
	^ Color fromHexString: '#FFC300'
]

{ #category : '*DebuggingSpy-Browser' }
StInspectorPresenter class >> windowType [

	^ 'Inspector'
]
