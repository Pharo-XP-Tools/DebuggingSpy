"
I record when the user selects code and inspects it.
"
Class {
	#name : 'DSInspectItRecord',
	#superclass : 'DSCodeActionRecord',
	#category : 'DebuggingSpy-Records',
	#package : 'DebuggingSpy',
	#tag : 'Records'
}

{ #category : 'accessing' }
DSInspectItRecord >> eventName [

	^ 'Inspect it'
]
