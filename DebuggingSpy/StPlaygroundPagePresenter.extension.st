Extension { #name : 'StPlaygroundPagePresenter' }

{ #category : '*DebuggingSpy' }
StPlaygroundPagePresenter >> forceDisableLoading [

	loading := false
]

{ #category : '*DebuggingSpy' }
StPlaygroundPagePresenter >> recordSelectedString [ 

	^ self selectedTextOrLine 
]
