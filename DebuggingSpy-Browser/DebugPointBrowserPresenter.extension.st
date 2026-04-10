Extension { #name : 'DebugPointBrowserPresenter' }

{ #category : '*DebuggingSpy-Browser' }
DebugPointBrowserPresenter class >> windowColor [

	<DSWindowColor>
	^ Color fromHexString: '#ff0fef'
]

{ #category : '*DebuggingSpy-Browser' }
DebugPointBrowserPresenter class >> windowType [

	^ 'Debug point browser'
]
