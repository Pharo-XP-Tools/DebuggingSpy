"
I record when a window is activated (click on the window or mouse over, depending on the settings).
"
Class {
	#name : 'DSWindowActivatedRecord',
	#superclass : 'DSWindowEventRecord',
	#category : 'DebuggingSpy-Records',
	#package : 'DebuggingSpy',
	#tag : 'Records'
}

{ #category : 'accessing' }
DSWindowActivatedRecord >> eventName [
	^'Window activated'
]
