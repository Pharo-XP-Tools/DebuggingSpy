Extension { #name : 'SpWindowPresenter' }

{ #category : '*DebuggingSpy-Tests' }
SpWindowPresenter >> basicPresenter: aPresenter [
	"Set the presenter to show as content of the window."

	aPresenter owner: self.
	presenter := aPresenter
]
