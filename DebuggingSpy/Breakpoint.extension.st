Extension { #name : 'Breakpoint' }

{ #category : '*DebuggingSpy' }
Breakpoint >> breakpointRecordFor: aBreakpointEvent [
	^DSBreakpointEventRecord for: aBreakpointEvent 
]
