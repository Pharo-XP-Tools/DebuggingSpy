"
I record when the user selects code and debugs it.
"
Class {
	#name : 'DSPrintItRecord',
	#superclass : 'DSCodeActionRecord',
	#category : 'DebuggingSpy-Records',
	#package : 'DebuggingSpy',
	#tag : 'Records'
}

{ #category : 'accessing' }
DSPrintItRecord >> eventName [ 
	^'Print it'
]
