"
I logs DSRecords objects into a JSON file.
"
Class {
	#name : 'DSJSONFileLogger',
	#superclass : 'Object',
	#category : 'DebuggingSpy-Loggers',
	#package : 'DebuggingSpy',
	#tag : 'Loggers'
}

{ #category : 'utilities' }
DSJSONFileLogger class >> objectToDict: anObject [

	| instanceVariableNames dict_object |
	dict_object := {
		               ('name' -> anObject class asString).
		               ('attributes' -> Dictionary new) } asDictionary.
	(instanceVariableNames := anObject class stonAllInstVarNames) isEmpty ifFalse: [
		instanceVariableNames do: [ :each | (dict_object at: 'attributes') at: each asSymbol put: (anObject instVarNamed: each) ] ].
	^ dict_object
]
