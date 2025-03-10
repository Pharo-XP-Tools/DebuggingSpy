Class {
	#name : 'DSBreakpointRemoved',
	#superclass : 'DSMethodBreakpointRecord',
	#category : 'DebuggingSpy-Records-Extensions',
	#package : 'DebuggingSpy',
	#tag : 'Records-Extensions'
}

{ #category : 'accessing' }
DSBreakpointRemoved >> eventSymbol [
	^'-b'
]
