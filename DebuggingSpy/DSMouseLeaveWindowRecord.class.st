"
This record is generated when the mouse leaves a window (with or without focus).
"
Class {
	#name : 'DSMouseLeaveWindowRecord',
	#superclass : 'DSMouseEventRecord',
	#category : 'DebuggingSpy-Records',
	#package : 'DebuggingSpy',
	#tag : 'Records'
}

{ #category : 'accessing' }
DSMouseLeaveWindowRecord >> eventName [
	^'Leave window'
]
