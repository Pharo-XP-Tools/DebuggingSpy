"
This record is generated when the mouse enters a window (with or without focus).
"
Class {
	#name : 'DSMouseEnterWindowRecord',
	#superclass : 'DSMouseEventRecord',
	#category : 'DebuggingSpy-Records',
	#package : 'DebuggingSpy',
	#tag : 'Records'
}

{ #category : 'accessing' }
DSMouseEnterWindowRecord >> eventName [

	toolInfo ifNil: [ ^ 'Enter ' , DSWindowRecord unknownWindow ].
	^ 'Enter ' , toolInfo windowType
]
