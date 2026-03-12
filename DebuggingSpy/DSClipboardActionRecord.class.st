"
I record clipboard actions such as copy and paste.
The records might include the clipboard text if the the shared variable #registerClipboardText is true (default value is false).
The record also includes the windowId and the editor class name.
"
Class {
	#name : 'DSClipboardActionRecord',
	#superclass : 'DSAbstractEventRecord',
	#instVars : [
		'clipboardText',
		'editorClassName'
	],
	#category : 'DebuggingSpy-Records',
	#package : 'DebuggingSpy',
	#tag : 'Records'
}

{ #category : 'examples' }
DSClipboardActionRecord class >> example [
	"Returns an exemple of object for this class."

	^ self new
		  record: (RubSmalltalkEditor new
				   textArea: RubEditingArea new;
				   yourself);
		  windowId: MorphicNativeWindow basicNew hash;
		  yourself
]

{ #category : 'accessing' }
DSClipboardActionRecord >> clipboardText [

	^ clipboardText
]

{ #category : 'accessing' }
DSClipboardActionRecord >> clipboardText: anObject [

	clipboardText := anObject
]

{ #category : 'accessing' }
DSClipboardActionRecord >> editorClassName [

	^ editorClassName
]

{ #category : 'accessing' }
DSClipboardActionRecord >> editorClassName: anObject [

	editorClassName := anObject
]

{ #category : 'actions api' }
DSClipboardActionRecord >> record: anEditor [

	self windowId: anEditor textArea window hash.
	editorClassName := anEditor class name
]
