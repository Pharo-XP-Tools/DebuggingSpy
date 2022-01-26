Class {
	#name : #DSSTONFileLoggerTest,
	#superclass : #TestCase,
	#instVars : [
		'logger',
		'survey',
		'task',
		'oldLogger'
	],
	#category : #'DebuggingSpy-Tests'
}

{ #category : #running }
DSSTONFileLoggerTest >> setUp [
	super setUp.
	oldLogger := DSSpy logger.
	logger := DSSTONFileLogger new.
	DSSpy logger: logger.
	survey := DSSurvey new.
	task := DSTask new
]

{ #category : #running }
DSSTONFileLoggerTest >> tearDown [

	DSSpy logger: oldLogger.
	super tearDown
]

{ #category : #'tests - file handling' }
DSSTONFileLoggerTest >> testDefaultLoggingDirectoryName [

	self
		assert: logger defaultLoggingDirectoryName
		equals: 'ds-spy'
]

{ #category : #'tests - file handling' }
DSSTONFileLoggerTest >> testDefaultLoggingFileName [
 	self assert: logger defaultLoggingFileName equals: SessionManager default currentSession id asString
]

{ #category : #'tests - file handling' }
DSSTONFileLoggerTest >> testEnsureCreateLoggingFileReference [

	| fileReference |
	fileReference := logger loggingDirectory / logger loggingFileName.
	fileReference ensureDelete.
	self deny: fileReference exists.
	logger ensureCreateLoggingFileReference.
	self assert: fileReference exists
]

{ #category : #'tests - task management' }
DSSTONFileLoggerTest >> testFilenameForSurvey [
	|fnameStream|
	fnameStream := (logger filenameForSurvey: survey) readStream.
	self assert: (fnameStream readStream upTo: $_) equals: survey uuid asString.
	self assert: (fnameStream readStream upTo: $.) equals: logger defaultLoggingFileName.
	self assert: (fnameStream readStream upToEnd) equals: logger surveyFileExtension
]

{ #category : #'tests - task management' }
DSSTONFileLoggerTest >> testForceLoggingFileNameFor [
	logger reset.
	logger forceLoggingFileNameFor: task.	
	self assert: logger loggingFileName equals: (task name, '-', SessionManager default currentSession id asString).
	self assert: logger loggingFileName equals: logger loggingFileReference basename.
	self assert: logger loggingFileReference exists
]

{ #category : #'tests - task management' }
DSSTONFileLoggerTest >> testForceRunningTask [

	DSSpy resetSpy.
	DSSpy forceRunningTask: task.
	self
		assert: logger loggingFileName
		equals:
		task name , '-' , SessionManager default currentSession id asString
]

{ #category : #'tests - file handling' }
DSSTONFileLoggerTest >> testLoggingDirectory [

	self
		assert: logger loggingDirectory
		equals: logger defaultLoggingDirectoryName asFileReference 
]

{ #category : #'tests - file handling' }
DSSTONFileLoggerTest >> testLoggingFileName [

	self
		assert: logger loggingFileName
		equals: logger defaultLoggingFileName
]

{ #category : #'tests - file handling' }
DSSTONFileLoggerTest >> testLoggingFileNameAfterTaskEnded [

	DSSpy startTask: task.
	DSSpy endTask: task.
	self
		assert: logger loggingFileName
		equals: logger defaultLoggingFileName
]

{ #category : #'tests - file handling' }
DSSTONFileLoggerTest >> testLoggingFileNameAfterTaskStarted [
	
	DSSpy startTask: task.

	self
		assert: logger loggingFileName
		equals: (task name, '-', logger defaultLoggingFileName)
]

{ #category : #'tests - file handling' }
DSSTONFileLoggerTest >> testLoggingFileReference [

	| fileReference |
	fileReference := logger loggingFileReference.
	self
		assert: fileReference
		equals: logger loggingDirectory / logger loggingFileName.
	self assert: fileReference exists
]

{ #category : #tests }
DSSTONFileLoggerTest >> testReset [
	logger forceLoggingFileNameFor: task.
	logger reset.
	self
		assert: logger loggingFileName
		equals: logger defaultLoggingFileName
]

{ #category : #'tests - task management' }
DSSTONFileLoggerTest >> testSurveyFileExtension [
	self assert: logger surveyFileExtension equals: 'survey'
]

{ #category : #'tests - logging' }
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
