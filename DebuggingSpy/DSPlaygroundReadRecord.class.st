"
I record that a mouse entered a StPlayground's code, which may indicate that the developer is reading the code.
"
Class {
	#name : 'DSPlaygroundReadRecord',
	#superclass : 'DSPlaygroundRecord',
	#category : 'DebuggingSpy-Records',
	#package : 'DebuggingSpy',
	#tag : 'Records'
}

{ #category : 'accessing' }
DSPlaygroundReadRecord >> eventName [

	^ 'Playground read'
]
