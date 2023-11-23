Extension { #name : 'BreakpointAnnouncement' }

{ #category : '*DebuggingSpy' }
BreakpointAnnouncement >> recordBreakpoint [
	^self breakpoint breakpointRecordFor: self
]
