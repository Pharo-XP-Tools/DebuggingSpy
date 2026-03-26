Class {
	#name : 'DSAnonymizeTest',
	#superclass : 'TestCase',
	#category : 'DebuggingSpy-Anonymizer-Tests',
	#package : 'DebuggingSpy-Anonymizer-Tests'
}

{ #category : 'tests' }
DSAnonymizeTest >> testAbstractEventRecord [

	| record anonymousRecord |
	record := DSAbstractEventRecord new
		          windowId: 1;
		          yourself.
	anonymousRecord := record anonymize.
		
	self assert: anonymousRecord windowId equals: 1.
	self assert: anonymousRecord uuid equals: record uuid.
	self assert: anonymousRecord dateTime equals: record dateTime. 
]

{ #category : 'tests' }
DSAnonymizeTest >> testAbstractTaskRecord [

	| record anonymousRecord |
	record := DSAbstractTaskRecord new
		          windowId: 1;
		          record: MockObject new;
		          yourself.
	anonymousRecord := record anonymize.

	self assert: (anonymousRecord readSlotNamed: 'task') class equals: SmallInteger
]

{ #category : 'tests' }
DSAnonymizeTest >> testClipboardActionRecord [

	| record anonymousRecord |
	record := DSClipboardActionRecord new
		          windowId: 1;
		          record: (RubSmalltalkEditor new
				           textArea: RubEditingArea new;
				           yourself);
		          yourself.
	anonymousRecord := record anonymize.

	self assert: anonymousRecord editorClassName isNil.
	self assert: anonymousRecord clipboardText class equals: SmallInteger
]

{ #category : 'tests' }
DSAnonymizeTest >> testCodeActionRecord [

	| record anonymousRecord |
	record := DSCodeActionRecord new
		          windowId: 1;
		          record: (RubSmalltalkEditor new
				           textArea: RubEditingArea new;
				           yourself);
		          yourself.
	anonymousRecord := record anonymize.

	self assert: anonymousRecord selectedString class equals: SmallInteger
]

{ #category : 'tests' }
DSAnonymizeTest >> testHaltChangeRecord [

	| method record anonymousRecord |
	method := DSHaltChangeRecord >> #eventName.
	record := DSHaltChangeRecord new
		          windowId: 1;
		          record: DSHaltChangeRecord add;
		          haltData: (DSSpy indexesOfHaltNodesIn: method);
		          method: method name;
		          yourself.
	anonymousRecord := record anonymize.

	self assert: (anonymousRecord readSlotNamed: 'method') class equals: SmallInteger.
	self assert: anonymousRecord haltData isNil.
	self deny: anonymousRecord haltChange isNil
]

{ #category : 'tests' }
DSAnonymizeTest >> testHaltHitRecord [

	| sender record anonymousRecord |
	sender := thisContext sender sender sender sender sender.
	record := DSHaltHitRecord new
		          windowId: 1;
		          record: {
				          sender sourceNodeExecuted.
				          #halt };
		          yourself.
	anonymousRecord := record anonymize.

	self assert: (anonymousRecord readSlotNamed: 'method') class equals: SmallInteger.
	self deny: anonymousRecord once isNil.
	self deny: anonymousRecord conditional isNil.
	self deny: anonymousRecord selector isNil
]

{ #category : 'tests' }
DSAnonymizeTest >> testLoggingErrorRecord [

	| sender record anonymousRecord |
	sender := thisContext sender sender sender sender sender.
	record := DSLoggingErrorRecord new
		          windowId: 1;
		          record: #ERROR;
		          yourself.
	anonymousRecord := record anonymize.

	self assert: anonymousRecord event equals: #ERROR
]

{ #category : 'tests' }
DSAnonymizeTest >> testMethodEventRecord [

	| method record anonymousRecord |
	method := DSMethodEventRecord >> #record:.
	record := DSMethodEventRecord new
		          windowId: 1;
		          record: method;
		          yourself.
	anonymousRecord := record anonymize.

	self assert: anonymousRecord methodName class equals: SmallInteger.
	self assert: anonymousRecord methodSource isNil
]

{ #category : 'tests' }
DSAnonymizeTest >> testMouseEventRecord [

	| record anonymousRecord |
	record := DSMouseEventRecord new
		          windowId: 1;
		          record: StPulse new;
		          yourself.
	anonymousRecord := record anonymize.

	self deny: anonymousRecord toolInfo isNil
]

{ #category : 'tests' }
DSAnonymizeTest >> testSurveyRecord [

	| record anonymousRecord |
	record := DSSurveyRecord new
		          windowId: 1;
		          record: 'aSurvey';
		          yourself.
	anonymousRecord := record anonymize.

	self assert: anonymousRecord survey class equals: SmallInteger
]

{ #category : 'tests' }
DSAnonymizeTest >> testTaskSuccessRecord [

	| record anonymousRecord |
	record := DSTaskSuccessRecord new
		          windowId: 1;
		          record: {
				          MockObject new.
				          true };
		          yourself.
	anonymousRecord := record anonymize.

	self assert: (anonymousRecord readSlotNamed: 'task') class equals: SmallInteger.
	self assert: anonymousRecord success
]

{ #category : 'tests' }
DSAnonymizeTest >> testWindowEventRecord [

	| event toolInfo record anonymousRecord |
	event := WindowOpened new window: MorphicNativeWindow basicNew.
	
	record := DSWindowEventRecord new.
	record recordWindowIdFromEvent: event.
	record recordWindowNameFromEvent: event.
	
	toolInfo := DSToolInfo toolNamed: #StPlayground id: 0 windowId: record windowId.
	record toolInfo: toolInfo.
	
	anonymousRecord := record anonymize.

	self deny: anonymousRecord toolInfo isNil
]
