"
I log DSRecords as STON into files.
"
Class {
	#name : #DSSpySTONFileLogger,
	#superclass : #Object,
	#traits : 'TDSSpyLogger',
	#classTraits : 'TDSSpyLogger classTrait',
	#instVars : [
		'loggingDirectory',
		'loggingFilename',
		'loggingFileReference'
	],
	#category : #'DebuggingSpy-Loggers'
}

{ #category : #accessing }
DSSpySTONFileLogger >> defaultLoggingDirectoryName [
	^'ds-spy'
]

{ #category : #accessing }
DSSpySTONFileLogger >> defaultLoggingFileName [

	^ SessionManager default currentSession id asString
]

{ #category : #logging }
DSSpySTONFileLogger >> ensureCreateLoggingFileReference [

	| fname fr |
	fname := self loggingFileName.
	fr := self loggingDirectory / fname.
	fr ensureCreateFile.
	^ fr
]

{ #category : #'task management' }
DSSpySTONFileLogger >> filenameForSurvey: aSurvey [
	^aSurvey uuid asString , '_' , self defaultLoggingFileName, '.', self surveyFileExtension
]

{ #category : #'task management' }
DSSpySTONFileLogger >> forceLoggingFileNameFor: aTask [

	loggingFilename := aTask name , '-' , self defaultLoggingFileName.
	loggingFileReference := self ensureCreateLoggingFileReference 
]

{ #category : #logging }
DSSpySTONFileLogger >> log: aDSEventRecord [

	self writeToFile: (STON toString: aDSEventRecord)
]

{ #category : #accessing }
DSSpySTONFileLogger >> loggingDirectory [
	^loggingDirectory ifNil:[loggingDirectory := self defaultLoggingDirectoryName asFileReference] 
]

{ #category : #logging }
DSSpySTONFileLogger >> loggingDirectory: aStringOrFileReference [

	loggingDirectory := aStringOrFileReference asFileReferenceWithRelativePath / self defaultLoggingDirectoryName asFileReference.
	loggingDirectory ensureCreateDirectory
]

{ #category : #accessing }
DSSpySTONFileLogger >> loggingFileName [
	^loggingFilename ifNil:[loggingFilename := self defaultLoggingFileName] 
]

{ #category : #accessing }
DSSpySTONFileLogger >> loggingFileReference [

	^loggingFileReference ifNil:[loggingFileReference := self ensureCreateLoggingFileReference] 
]

{ #category : #logging }
DSSpySTONFileLogger >> stream [
	^ self loggingFileReference writeStream
]

{ #category : #'task management' }
DSSpySTONFileLogger >> surveyFileExtension [
	^'survey'
]

{ #category : #logging }
DSSpySTONFileLogger >> writeToFile: aString [

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
