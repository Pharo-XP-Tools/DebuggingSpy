"
I record breakpoint events information.
"
Class {
	#name : 'DSBreakDebugPointEventRecord',
	#superclass : 'DSAbstractDebugPointEventRecord',
	#category : 'DebuggingSpy-Records',
	#package : 'DebuggingSpy',
	#tag : 'Records'
}

{ #category : 'examples' }
DSBreakDebugPointEventRecord class >> example [
	"Returns an exemple of object for this class."

	| target debugPoint event |
	target := DSTestClassWithInstanceVariables new.

	debugPoint := DebugPointManager installNew: BreakDebugPoint forObject: target onVariableAccessNamed: #text.
	event := DebugPointAdded on: debugPoint nodes: debugPoint link nodes.
	
	^ self new
		  record: event;
		  windowId: MorphicNativeWindow basicNew hash;
		  yourself
]

{ #category : 'converting' }
DSBreakDebugPointEventRecord >> modelClass [

	^ DSMethodDebugPointRecord
]
