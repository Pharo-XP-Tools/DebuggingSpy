"
I am a fake text editor that inherits from RubTextEditor.
My purpose is to ease testing of instrumented methods from RubTextEditor without triggering a full behavior of the text editor that is in an incomplete state for the tests.
"
Class {
	#name : #DSFakeTextEditor,
	#superclass : #RubTextEditor,
	#category : #'DebuggingSpy-Tests'
}
