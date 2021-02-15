Extension { #name : #SpAbstractMorphicAdapter }

{ #category : #'*DebuggingSpy-Tests' }
SpAbstractMorphicAdapter >> sendMouseEnterEvent [

	| evt |
	evt := MouseMoveEvent new
		       setType: #mouseEnter
		       startPoint: widget center
		       endPoint: widget center
		       trail: nil
		       buttons: nil
		       hand: nil
		       stamp: nil.



	widget handleEvent: evt
]
