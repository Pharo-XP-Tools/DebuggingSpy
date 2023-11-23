Extension { #name : 'VariableBreakpoint' }

{ #category : '*DebuggingSpy' }
VariableBreakpoint >> breakpointRecordFor: aBreakpointEvent [
	^DSVariableBreakpointEventRecord for: aBreakpointEvent 
]
