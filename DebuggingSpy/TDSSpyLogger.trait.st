"
Common API for DSSpy surveys
"
Trait {
	#name : #TDSSpyLogger,
	#category : #'DebuggingSpy-Loggers'
}

{ #category : #setup }
TDSSpyLogger >> setupLoggerForSurvey: aSurvey [
	self explicitRequirement "self forceLoggingFileNameFor: aTask."
]

{ #category : #setup }
TDSSpyLogger >> setupLoggerForTask: aTask [
	self explicitRequirement
]
