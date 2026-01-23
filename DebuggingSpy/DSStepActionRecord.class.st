"
I record a debugging action from an opened debugger.
In addition to the debugger window id, I also record the signature of the context I am performing the action as well as the current node of that context.
In confidentiality mode, this signature and node should be replaced by the current pc instead.
"
Class {
	#name : 'DSStepActionRecord',
	#superclass : 'DSAbstractDebuggerActionRecord',
	#instVars : [
		'context',
		'node',
		'eventName',
		'receiver',
		'receiverClass'
	],
	#category : 'DebuggingSpy-Records',
	#package : 'DebuggingSpy',
	#tag : 'Records'
}

{ #category : 'converting' }
DSStepActionRecord >> asStepRecord [

	((SindarinCommand allSubclasses collect: #defaultName) includes:
		 eventName) ifTrue: [ ^ DSStepRecord sindarinStep: self ].

	^ DSStepRecord
		  perform:
			  (eventName asLowercase copyReplaceAll: ' ' with: '') asSymbol
				  asMutator
		  with: self
]

{ #category : 'accessing' }
DSStepActionRecord >> context [

	^ context
]

{ #category : 'as yet unclassified' }
DSStepActionRecord >> debuggingGlyphs [

	^ Dictionary newFromPairs:
		  { 'Over'. '>'. 'Into'. 'V'. 'Through'. '>>'. 'Restart'. 'R'. 'Proceed'.
		  'P' }
]

{ #category : 'accessing' }
DSStepActionRecord >> eventName [
	^eventName
]

{ #category : 'as yet unclassified' }
DSStepActionRecord >> glyph [

	^ self debuggingGlyphs at: self eventName
]

{ #category : 'as yet unclassified' }
DSStepActionRecord >> glyphColor [

	^ Color red darker
]

{ #category : 'accessing' }
DSStepActionRecord >> node [

	^ node
]

{ #category : 'accessing' }
DSStepActionRecord >> printContext [

	^ (self context printStringLimitedTo: 30 ), self node
]

{ #category : 'printing' }
DSStepActionRecord >> printContextAndNode [

	^ String streamContents: [ :s |
		  | nodeStream peek |
		  s << '['.
		  s << context.
		  s << ']'.
		  s space.
		  nodeStream := node readStream.
		  peek := nodeStream upTo: $(.

		  s << (nodeStream atEnd
			   ifTrue: [ peek ]
			   ifFalse: [ nodeStream upTo: $) ]) ]
]

{ #category : 'accessing' }
DSStepActionRecord >> receiver [

	^ receiver
]

{ #category : 'accessing' }
DSStepActionRecord >> receiverClass [

	^ receiverClass
]

{ #category : 'actions api' }
DSStepActionRecord >> record: aDSDebuggerCommand [
	super record: aDSDebuggerCommand context window window.
	eventName := aDSDebuggerCommand class defaultName.
	context := aDSDebuggerCommand context currentContext printString.
	node := aDSDebuggerCommand context currentContext sourceNodeExecuted printString.
	receiver := aDSDebuggerCommand context currentContext receiver printString.
	receiverClass := aDSDebuggerCommand context currentContext receiver class name
]
