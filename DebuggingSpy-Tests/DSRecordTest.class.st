Class {
	#name : 'DSRecordTest',
	#superclass : 'TestCase',
	#instVars : [
		'record'
	],
	#category : 'DebuggingSpy-Tests',
	#package : 'DebuggingSpy-Tests'
}

{ #category : 'tests' }
DSRecordTest >> testRecordPrinting [

	| str |
	str := WriteStream on: String new.
	record := DSTestRecord new.
	record printOn: str.
	self assert: str contents equals: record eventName
]
