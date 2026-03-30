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
		          task: MockObject new;
		          yourself.
	anonymousRecord := record anonymize.

	self assert: anonymousRecord task class equals: MockObject
]

{ #category : 'tests' }
DSAnonymizeTest >> testClipboardActionRecord [

	| record anonymousRecord |
	record := DSClipboardActionRecord new
		          windowId: 1;
		          clipboardText: 'someText';
		          editorClassName: 'someClass';
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
		          selectedString: 'someString';
		          yourself.
	anonymousRecord := record anonymize.

	self assert: anonymousRecord selectedString class equals: SmallInteger
]

{ #category : 'tests' }
DSAnonymizeTest >> testHaltChangeRecord [

	| record anonymousRecord |
	record := DSHaltChangeRecord new
		          haltChange: 'haltChangeValue';
		          haltData: 'haltDataValue';
		          sourceCodeInterval: 'sourceCodeIntervalValue';
		          method: 'aMethod';
		          yourself.
	anonymousRecord := record anonymize.

	self assert: anonymousRecord method class equals: SmallInteger.
	self assert: anonymousRecord sourceCodeInterval isNil.
	self assert: anonymousRecord haltData isNil.
	self assert: anonymousRecord haltChange equals: 'haltChangeValue'
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
		          event: #ERROR;
		          yourself.
	anonymousRecord := record anonymize.

	self assert: anonymousRecord event equals: #ERROR
]

{ #category : 'tests' }
DSAnonymizeTest >> testMethodEventRecord [

	| record anonymousRecord |
	record := DSMethodEventRecord new
		          windowId: 1;
		          methodName: 'methodName';
		          methodSource: 'methodSource';
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
		          survey: 'aSurvey';
		          yourself.
	anonymousRecord := record anonymize.

	self assert: anonymousRecord survey class equals: SmallInteger
]

{ #category : 'tests' }
DSAnonymizeTest >> testTaskSuccessRecord [

	| record anonymousRecord |
	record := DSTaskSuccessRecord new
		          windowId: 1;
		          success: true;
		          yourself.
	anonymousRecord := record anonymize.

	self assert: anonymousRecord success
]

{ #category : 'tests' }
DSAnonymizeTest >> testUnhandledExceptionRecord [

	| record anonymousRecord |
	record := DSUnhandledExceptionRecord new
		          exceptionClass: 'anExceptionClass';
		          errorString: 'anErrorString';
		          receiver: 'aReceiver';
		          node: 'aNode';
		          method: 'aMethod';
		          yourself.

	anonymousRecord := record anonymize.

	self assert: anonymousRecord exceptionClass class equals: SmallInteger.
	self assert: anonymousRecord method class equals: SmallInteger.
	self assert: anonymousRecord errorString class equals: SmallInteger.
	self assert: anonymousRecord node class equals: SmallInteger.
	self assert: anonymousRecord receiver class equals: SmallInteger
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
