Class {
	#name : 'DSToolInfoTest',
	#superclass : 'TestCase',
	#category : 'DebuggingSpy-Anonymizer-Tests',
	#package : 'DebuggingSpy-Anonymizer-Tests'
}

{ #category : 'tests' }
DSToolInfoTest >> testAnonymizeWithCorrectTool [

	| tool |
	tool := DSToolInfo toolClass: StPlayground id: 0 windowId: 1.
	tool := tool anonymize.

	self assert: tool toolClass equals: StPlayground.
	self assert: tool toolIdentityHash equals: 0.
	self assert: tool windowIdentityHash equals: 1
]

{ #category : 'tests' }
DSToolInfoTest >> testAnonymizeWithIncorrectTool [

	| tool |
	tool := DSToolInfo toolClass: DSRecordDataFilter id: 0 windowId: 1.
	tool := tool anonymize.

	self assert: tool toolClass equals: DSRecordDataFilter identityHash.
	self assert: tool toolIdentityHash equals: 0.
	self assert: tool windowIdentityHash equals: 1
]
