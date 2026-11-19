"
I am a testing object for serialization of objects. 
"
Class {
	#name : 'DSTestObject',
	#superclass : 'Object',
	#instVars : [
		'first',
		'second',
		'other'
	],
	#category : 'DebuggingSpy-Tests-Utils',
	#package : 'DebuggingSpy-Tests',
	#tag : 'Utils'
}

{ #category : 'accessing' }
DSTestObject >> first [

	^ first 
]

{ #category : 'accessing' }
DSTestObject >> first: anObject [

	first := anObject 
]

{ #category : 'accessing' }
DSTestObject >> other [

	^ other
]

{ #category : 'accessing' }
DSTestObject >> other: anObject [

	other := anObject
]

{ #category : 'accessing' }
DSTestObject >> second [

	^ second 
]

{ #category : 'accessing' }
DSTestObject >> second: anObject [

	second := anObject
]
