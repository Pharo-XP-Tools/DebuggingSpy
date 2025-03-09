"
I record that a StPlayground opened.
"
Class {
	#name : 'DSPlaygroundOpenedRecord',
	#superclass : 'DSPlaygroundRecord',
	#category : 'DebuggingSpy-Records',
	#package : 'DebuggingSpy',
	#tag : 'Records'
}

{ #category : 'accessing' }
DSPlaygroundOpenedRecord >> eventName [
	^'Playground open' 
]
