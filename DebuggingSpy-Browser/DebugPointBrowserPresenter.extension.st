Extension { #name : 'DebugPointBrowserPresenter' }

{ #category : '*DebuggingSpy-Browser' }
DebugPointBrowserPresenter class >> windowColor [

	<DSWindowColor>
	^ Color fromHexString: '#7C238C'
]

{ #category : '*DebuggingSpy-Browser' }
DebugPointBrowserPresenter class >> windowType [

	^ 'Debug point browser'
]
