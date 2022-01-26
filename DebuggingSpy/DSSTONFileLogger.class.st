"
I log DSRecords as STON into files.
"
Class {
	#name : #DSSTONFileLogger,
	#superclass : #Object,
	#traits : 'TDSLogger',
	#classTraits : 'TDSLogger classTrait',
	#instVars : [
		'loggingDirectory',
		'loggingFilename',
		'loggingFileReference'
	],
	#category : #'DebuggingSpy-Loggers'
}

{ #category : #accessing }
DSSTONFileLogger >> defaultLoggingDirectoryName [
	^'ds-spy'
]

{ #category : #accessing }
DSSTONFileLogger >> defaultLoggingFileName [

	^ SessionManager default currentSession id asString
]

{ #category : #logging }
DSSTONFileLogger >> ensureCreateLoggingFileReference [

	| fname fr |
	fname := self loggingFileName.
	fr := self loggingDirectory / fname.
	fr ensureCreateFile.
	^ fr
]

{ #category : #'task management' }
DSSTONFileLogger >> filenameForSurvey: aSurvey [
	^aSurvey uuid asString , '_' , self defaultLoggingFileName, '.', self surveyFileExtension
]

{ #category : #'task management' }
DSSTONFileLogger >> forceLoggingFileNameFor: aTask [

	loggingFilename := aTask name , '-' , self defaultLoggingFileName.
	loggingFileReference := self ensureCreateLoggingFileReference 
]

{ #category : #logging }
DSSTONFileLogger >> log: aDSEventRecord [

	self writeToFile: (STON toString: aDSEventRecord)
]

{ #category : #accessing }
DSSTONFileLogger >> loggingDirectory [
	^loggingDirectory ifNil:[loggingDirectory := self defaultLoggingDirectoryName asFileReference] 
]

{ #category : #logging }
DSSTONFileLogger >> loggingDirectory: aStringOrFileReference [

	loggingDirectory := aStringOrFileReference asFileReferenceWithRelativePath / self defaultLoggingDirectoryName asFileReference.
	loggingDirectory ensureCreateDirectory
]

{ #category : #accessing }
DSSTONFileLogger >> loggingFileName [
	^loggingFilename ifNil:[loggingFilename := self defaultLoggingFileName] 
]

{ #category : #accessing }
DSSTONFileLogger >> loggingFileReference [

	^loggingFileReference ifNil:[loggingFileReference := self ensureCreateLoggingFileReference] 
]

{ #category : #setup }
DSSTONFileLogger >> setupLoggerForSurvey: aSurvey [
	"self forceLoggingFileNameFor: aTask".
]

{ #category : #setup }
DSSTONFileLogger >> setupLoggerForTask: aTask [

	self forceLoggingFileNameFor: aTask
]

{ #category : #logging }
DSSTONFileLogger >> stream [
	^ self loggingFileReference writeStream
]

{ #category : #'task management' }
DSSTONFileLogger >> surveyFileExtension [
	^'survey'
]

{ #category : #logging }
DSSTONFileLogger >> writeToFile: aString [

	| str strSize firstWrite writingPosition |
	str := self stream.
	strSize := str writeStreamSize.
	firstWrite := strSize = 0.
	firstWrite ifTrue: [ str nextPut: $[ ].
	writingPosition := firstWrite
		                   ifTrue: [ str position ]
		                   ifFalse: [ strSize - 1 ].
	str position: writingPosition.
	firstWrite ifFalse: [ 
		str nextPut: $,.
		str crlf ].
	str nextPutAll: aString.
	str nextPut: $].
	str close
]
