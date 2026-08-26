"
I am a class representing a test record for filter features.
"
Class {
	#name : 'DSTestFilterRecord',
	#superclass : 'DSAbstractEventRecord',
	#instVars : [
		'first',
		'second'
	],
	#category : 'DebuggingSpy-Anonymizer-Tests',
	#package : 'DebuggingSpy-Anonymizer-Tests'
}

{ #category : 'accessing' }
DSTestFilterRecord >> eventName [

	^ 'test record for filter'
]

{ #category : 'filtering' }
DSTestFilterRecord >> filterFirstValue [

	^ DSRecordDataFilter new
		  with: #second;
		  applyOn: self
]

{ #category : 'accessing' }
DSTestFilterRecord >> first [
	^first
]

{ #category : 'accessing' }
DSTestFilterRecord >> first: aValue [
	first := aValue
]

{ #category : 'accessing' }
DSTestFilterRecord >> second [
	^second
]

{ #category : 'accessing' }
DSTestFilterRecord >> second: aValue [
	second := aValue
]
