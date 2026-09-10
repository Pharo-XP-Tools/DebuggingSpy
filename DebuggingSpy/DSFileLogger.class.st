"
I am an abstract class for DSSpy loggers.
"
Class {
	#name : 'DSFileLogger',
	#superclass : 'Object',
	#classTraits : 'TExperimentLogger classTrait',
	#classInstVars : [
		'loggingFileName',
		'loggingDirectory',
		'savedConfiguration',
		'loggingFileReference'
	],
	#category : 'DebuggingSpy-Loggers',
	#package : 'DebuggingSpy',
	#tag : 'Loggers'
}

{ #category : 'accessing' }
DSFileLogger class >> defaultLoggingDirectoryName [

	^ DSSpy testingSession
		  ifTrue: [ 'tests' ]
		  ifFalse: [ 'ds-spy' ]
]

{ #category : 'accessing' }
DSFileLogger class >> defaultLoggingFileName [

	^ DSSpy getRecordFileName 
]

{ #category : 'logging' }
DSFileLogger class >> ensureCreateLoggingFileReference [

	| fileName fileReference |
	fileName := self loggingFileName.
	fileReference := self loggingDirectory / fileName.
	fileReference ensureCreateFile.
	^ fileReference
]

{ #category : 'task management' }
DSFileLogger class >> filenameForSurvey: aSurvey [

	^ aSurvey uuid asString , '_' , self defaultLoggingFileName , '.' , self surveyFileExtension
]

{ #category : 'task management' }
DSFileLogger class >> forceLoggingFileNameFor: aTask [

	loggingFileName := aTask title , '-' , self defaultLoggingFileName.
	loggingFileReference := self ensureCreateLoggingFileReference
]

{ #category : 'logging' }
DSFileLogger class >> log: aDSEventRecord [

	self subclassResponsibility
]

{ #category : 'accessing' }
DSFileLogger class >> loggingDirectory [

	^ loggingDirectory ifNil: [ loggingDirectory := self defaultLoggingDirectoryName asFileReference ]
]

{ #category : 'logging' }
DSFileLogger class >> loggingDirectory: aStringOrFileReference [

	loggingDirectory := aStringOrFileReference asFileReference / self defaultLoggingDirectoryName.
	loggingDirectory ensureCreateDirectory
]

{ #category : 'accessing' }
DSFileLogger class >> loggingFileName [

	^ loggingFileName ifNil: [ loggingFileName := self defaultLoggingFileName ]
]

{ #category : 'accessing' }
DSFileLogger class >> loggingFileName: aFileName [

	loggingFileName := aFileName
]

{ #category : 'accessing' }
DSFileLogger class >> loggingFileReference [

	^ loggingFileReference ifNil: [ loggingFileReference := self ensureCreateLoggingFileReference ]
]

{ #category : 'accessing' }
DSFileLogger class >> loggingFileReference: aFileReference [

	loggingFileReference := aFileReference
]

{ #category : 'class initialization' }
DSFileLogger class >> reset [

	loggingDirectory := nil.
	loggingFileName := nil.
	loggingFileReference := nil
]

{ #category : 'private' }
DSFileLogger class >> restoreCurrentConfiguration [

	loggingFileName := self savedConfiguration at: #currentLoggingFilename.
	loggingFileReference := self savedConfiguration at: #currentLoggingFileReference
]

{ #category : 'private' }
DSFileLogger class >> saveCurrentConfiguration [

	self savedConfiguration
		at: #currentLoggingFilename put: loggingFileName;
		at: #currentLoggingFileReference put: loggingFileReference
]

{ #category : 'accessing' }
DSFileLogger class >> savedConfiguration [

	^ savedConfiguration ifNil: [ savedConfiguration := Dictionary new ]
]

{ #category : 'setup' }
DSFileLogger class >> setupLoggerAfterSurvey: aSurvey [

	self restoreCurrentConfiguration
]

{ #category : 'setup' }
DSFileLogger class >> setupLoggerBeforeSurvey: aSurvey [

	self saveCurrentConfiguration.
	loggingFileName := self filenameForSurvey: aSurvey.
	loggingFileReference := self ensureCreateLoggingFileReference
]

{ #category : 'setup' }
DSFileLogger class >> setupLoggerForTask: aTask [

	self forceLoggingFileNameFor: aTask
]

{ #category : 'logging' }
DSFileLogger class >> stream [

	^ self loggingFileReference writeStream
]

{ #category : 'task management' }
DSFileLogger class >> surveyFileExtension [

	^ 'survey'
]

{ #category : 'logging' }
DSFileLogger class >> writeToFile: aString [

	self subclassResponsibility 
]
