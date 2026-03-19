Class {
	#name : 'DSToolInfoTest',
	#superclass : 'TestCase',
	#category : 'DebuggingSpy-Anonymizer-Tests',
	#package : 'DebuggingSpy-Anonymizer-Tests'
}

{ #category : 'tests' }
DSToolInfoTest >> testAnonymizeWithCorrectTool [

	| tool |
	tool := DSToolInfo toolNamed: #StPlayground id: 0 windowId: 1.
	tool := tool anonymize.
	
	self assert: tool toolClassName equals: #StPlayground.
	self assert: tool toolIdentityHash equals: 0.
	self assert: tool windowIdentityHash equals: 1.
	
	
]

{ #category : 'tests' }
DSToolInfoTest >> testAnonymizeWithIncorrectTool [

	| tool |
	self deny: (SystemBuildInfo current systemPackages includes: (self class environment at: #DSRecordDataFilter) package).

	tool := DSToolInfo toolNamed: #DSRecordDataFilter id: 0 windowId: 1.
	tool := tool anonymize.

	self assert: tool toolClassName equals: #DSRecordDataFilter identityHash.
	self assert: tool toolIdentityHash equals: 0.
	self assert: tool windowIdentityHash equals: 1
]

{ #category : 'tests' }
DSToolInfoTest >> testAnonymizeWithUnknownTool [

	| toolName tool |
	toolName := UUID new asString.
	self deny: (self class environment includes: toolName asSymbol).

	tool := DSToolInfo toolNamed: toolName asSymbol id: 0 windowId: 1.
	self should: [ tool anonymize ] raise: KeyNotFound
]
