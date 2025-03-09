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

{ #category : #accessing }
DSMouseEnterTextEditorRecord >> windowName [
	^ windowId
]

{ #category : #'as yet unclassified' }
DSMouseEnterTextEditorRecord >> windowType [

	^ 'External Window'
]
