Class {
	#name : 'DSSTONFileLoggerTest',
	#superclass : 'TestCase',
	#instVars : [
		'survey',
		'task',
		'logger'
	],
	#category : 'DebuggingSpy-Tests-Tests - model',
	#package : 'DebuggingSpy-Tests',
	#tag : 'Tests - model'
}

{ #category : 'running' }
DSSTONFileLoggerTest >> setUp [
	super setUp.
	DSSpy testingSession: true.
	logger := DSSpy logger.
	survey := DSTestSurvey new.
	task := DSTestTask new
]

{ #category : 'running' }
DSSTONFileLoggerTest >> tearDown [

	DSSpy resetSpy.
	DSRecordRegistry current reset.
	
	'tests' asFileReference ensureDeleteAll.
	super tearDown
]

{ #category : 'tests - file handling' }
DSSTONFileLoggerTest >> testDefaultLoggingDirectoryName [

	self assert: logger defaultLoggingDirectoryName equals: 'tests'.

	DSSpy testingSession: false.

	self assert: logger defaultLoggingDirectoryName equals: 'ds-spy'
]

{ #category : 'tests - file handling' }
DSSTONFileLoggerTest >> testDefaultLoggingFileName [
 	self assert: logger defaultLoggingFileName equals: DSSpy getRecordFileName 
]

{ #category : 'tests - file handling' }
DSSTONFileLoggerTest >> testEnsureCreateLoggingFileReference [

	| fileReference |
	fileReference := logger loggingDirectory / logger loggingFileName.
	self deny: fileReference exists.
	fileReference := logger ensureCreateLoggingFileReference.
	self assert: fileReference exists
]

{ #category : 'tests - task management' }
DSSTONFileLoggerTest >> testFilenameForSurvey [
	|fnameStream|
	fnameStream := (logger filenameForSurvey: survey) readStream.
	self assert: (fnameStream readStream upTo: $_) equals: survey uuid asString.
	self assert: (fnameStream readStream upTo: $.) equals: logger defaultLoggingFileName.
	self assert: (fnameStream readStream upToEnd) equals: logger surveyFileExtension
]

{ #category : 'tests - task management' }
DSSTONFileLoggerTest >> testForceLoggingFileNameFor [
	logger reset.
	logger forceLoggingFileNameFor: task.	
	self assert: logger loggingFileName equals: (task title, '-', DSSpy getRecordFileName).
	self assert: logger loggingFileName equals: logger loggingFileReference basename.
	self assert: logger loggingFileReference exists
]

{ #category : 'tests - task management' }
DSSTONFileLoggerTest >> testForceRunningTask [

	DSSpy forceRunningTask: task.
	self assert: logger loggingFileName equals: task title , '-' , DSSpy getRecordFileName
]

{ #category : 'tests - file handling' }
DSSTONFileLoggerTest >> testLoggingDirectory [

	self
		assert: logger loggingDirectory
		equals: logger defaultLoggingDirectoryName asFileReference 
]

{ #category : 'tests - file handling' }
DSSTONFileLoggerTest >> testLoggingFileName [

	self
		assert: logger loggingFileName
		equals: logger defaultLoggingFileName
]

{ #category : 'tests - file handling' }
DSSTONFileLoggerTest >> testLoggingFileNameAfterTaskEnded [

	DSSpy startTask: task.
	DSSpy endTask: task.
	self
		assert: logger loggingFileName
		equals: logger defaultLoggingFileName
]

{ #category : 'tests - file handling' }
DSSTONFileLoggerTest >> testLoggingFileNameAfterTaskStarted [
	
	DSSpy startTask: task.

	self
		assert: logger loggingFileName
		equals: (task title, '-', logger defaultLoggingFileName)
]

{ #category : 'tests - file handling' }
DSSTONFileLoggerTest >> testLoggingFileReference [

	| fileReference |
	fileReference := logger loggingFileReference.
	self
		assert: fileReference
		equals: logger loggingDirectory / logger loggingFileName.
	self assert: fileReference exists
]

{ #category : 'tests' }
DSSTONFileLoggerTest >> testReset [
	logger forceLoggingFileNameFor: task.
	logger reset.
	self
		assert: logger loggingFileName
		equals: logger defaultLoggingFileName
]

{ #category : 'tests - task management' }
DSSTONFileLoggerTest >> testSurveyFileExtension [
	self assert: logger surveyFileExtension equals: 'survey'
]

{ #category : 'tests - logging' }
DSSTONFileLoggerTest >> testWriteToFile [

	| str |
	logger loggingFileReference ensureDelete.
	logger writeToFile: 'test'.
	self
		assert: logger loggingFileReference readStream contents
		equals: '[test]'.
	logger writeToFile: 'test'.

	str := WriteStream on: String new.
	str << '['.
	str << 'test'.
	str << ','.
	str crlf.
	str << 'test'.
	str << ']'.

	self
		assert: logger loggingFileReference readStream contents
		equals: str contents
]
