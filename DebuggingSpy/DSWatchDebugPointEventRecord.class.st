"
I record variable breakpoint events information.
"
Class {
	#name : 'DSWatchDebugPointEventRecord',
	#superclass : 'DSAbstractDebugPointEventRecord',
	#instVars : [
		'history',
		'limit'
	],
	#category : 'DebuggingSpy-Records',
	#package : 'DebuggingSpy',
	#tag : 'Records'
}

{ #category : 'examples' }
DSWatchDebugPointEventRecord class >> example [
	"Returns an exemple of object for this class."

	| target debugPoint event |
	target := DSTestClassWithInstanceVariables new.

	debugPoint := DebugPointManager installNew: WatchDebugPoint forObject: target onVariableAccessNamed: #text.
	event := DebugPointAdded on: debugPoint nodes: debugPoint link nodes.
	
	^ self new
		  record: event;
		  windowId: MorphicNativeWindow basicNew identityHash;
		  yourself
]

{ #category : 'accessing' }
DSWatchDebugPointEventRecord >> history [

	^ history
]

{ #category : 'accessing' }
DSWatchDebugPointEventRecord >> limit [

	^ limit
]

{ #category : 'converting' }
DSWatchDebugPointEventRecord >> modelClass [

	^ DSMethodDebugPointRecord 
]

{ #category : 'actions api' }
DSWatchDebugPointEventRecord >> record: aDebugPointEvent [
	super record: aDebugPointEvent.
	limit := aDebugPointEvent debugPoint limit.
	history := aDebugPointEvent debugPoint history.
]
