"
This record is generated when the mouse enters an item in a text editor.
"
Class {
	#name : 'DSMouseEnterTextEditorRecord',
	#superclass : 'DSMouseEventRecord',
	#category : 'DebuggingSpy-Records',
	#package : 'DebuggingSpy',
	#tag : 'Records'
}

{ #category : 'accessing' }
DSMouseEnterTextEditorRecord >> eventName [
	^'Mouse on text editor'
]

{ #category : 'accessing' }
DSMouseEnterTextEditorRecord >> windowName [
	^ windowId
]

{ #category : 'accessing' }
DSMouseEnterTextEditorRecord >> windowType [

	^ 'External Window'
]
