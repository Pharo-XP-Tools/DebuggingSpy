"
I record when a window is opened.
"
Class {
	#name : 'DSWindowOpenedRecord',
	#superclass : 'DSWindowEventRecord',
	#category : 'DebuggingSpy-Records',
	#package : 'DebuggingSpy',
	#tag : 'Records'
}

{ #category : 'accessing' }
DSWindowOpenedRecord >> eventName [

	toolInfo ifNil: [ ^ DSWindowRecord unknownWindow , ' opened' ].
	^ toolInfo windowType , ' opened'
]
