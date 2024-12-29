"
I record a scrolling event somewhere in a FTTableMorph or a GeneralScrollPane.
To identify where I am scrolling, use the window id recorded by my superclass.
"
Class {
	#name : 'DSScrollEventRecord',
	#superclass : 'DSAbstractEventRecord',
	#category : 'DebuggingSpy-Records',
	#package : 'DebuggingSpy',
	#tag : 'Records'
}

{ #category : 'accessing' }
DSScrollEventRecord >> eventName [
	^'Scrolling'
]
