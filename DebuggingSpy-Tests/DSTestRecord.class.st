"
I am an event record class to test ds records mechanics.

I have two slots: #first and #second that are used to test filtering features.
"
Class {
	#name : 'DSTestRecord',
	#superclass : 'DSAbstractEventRecord',
	#instVars : [
		'first',
		'second'
	],
	#category : 'DebuggingSpy-Tests-Utils',
	#package : 'DebuggingSpy-Tests',
	#tag : 'Utils'
}

{ #category : 'accessing' }
DSTestRecord >> eventName [
	^'test'
]

{ #category : 'evaluating' }
DSTestRecord >> first [

	^ first
]

{ #category : 'accessing' }
DSTestRecord >> first: aValue [

	first := aValue
]

{ #category : 'evaluating' }
DSTestRecord >> second [

	^ second
]

{ #category : 'accessing' }
DSTestRecord >> second: aValue [

	second := aValue
]
