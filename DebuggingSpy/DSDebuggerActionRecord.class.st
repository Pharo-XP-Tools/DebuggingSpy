"
I record debugger actions such as step, stepOver, etc.
The name of the action is stored in my event name
"
Class {
	#name : 'DSDebuggerActionRecord',
	#superclass : 'DSDebuggerRecord',
	#instVars : [
		'eventName'
	],
	#category : 'DebuggingSpy-Records',
	#package : 'DebuggingSpy',
	#tag : 'Records'
}

{ #category : 'tests - instance creation' }
DSDebuggerActionRecord class >> into: aContext [

	^ (self for: aContext)
		  eventName: 'Into';
		  yourself
]

{ #category : 'tests - instance creation' }
DSDebuggerActionRecord class >> over: aContext [

	^ (self for: aContext)
		  eventName: 'Over';
		  yourself
]

{ #category : 'tests - instance creation' }
DSDebuggerActionRecord class >> proceed: aContext [

	^ (self for: aContext)
		  eventName: 'Proceed';
		  yourself
]

{ #category : 'tests - instance creation' }
DSDebuggerActionRecord class >> restart: aContext [

	^ (self for: aContext)
		  eventName: 'Restart';
		  yourself
]

{ #category : 'tests - instance creation' }
DSDebuggerActionRecord class >> return: aContext [

	^ (self for: aContext)
		  eventName: 'Return';
		  yourself
]

{ #category : 'tests - instance creation' }
DSDebuggerActionRecord class >> runTo: aContext [

	^ (self for: aContext)
		  eventName: 'Run to';
		  yourself
]

{ #category : 'tests - instance creation' }
DSDebuggerActionRecord class >> through: aContext [

	^ (self for: aContext)
		  eventName: 'Through';
		  yourself
]

{ #category : 'accessing' }
DSDebuggerActionRecord >> eventName [
	^eventName
]

{ #category : 'accessing' }
DSDebuggerActionRecord >> eventName: anObject [

	eventName := anObject
]

{ #category : 'actions api' }
DSDebuggerActionRecord >> record: aContext [ 
	super record: aContext.
	
]
