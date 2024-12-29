"
I am a debugger opening strategy that eat all debugger opening requests to avoid opening debuggers during testing.
"
Class {
	#name : 'DSNoDebuggerSelectionStrategy',
	#superclass : 'OupsDebuggerSelectionStrategy',
	#category : 'DebuggingSpy-Tests',
	#package : 'DebuggingSpy-Tests'
}

{ #category : 'iterating' }
DSNoDebuggerSelectionStrategy >> nextDebugger [
	^ self
]

{ #category : 'debuggers' }
DSNoDebuggerSelectionStrategy >> openDebuggerForSession: aDebugSession [
	^self 
]
