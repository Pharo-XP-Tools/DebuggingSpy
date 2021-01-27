"
I record different kinds of mouse events in order to track what the users moves the mouse and on what items he is clicking.
For example the following events:
- mouse enter windows W that is a class browser
- mouse click on the item corresponding to the method #foo
means the user is currently browsing the method foo (and we assume there she reads the code)..
"
Class {
	#name : #DSMouseEventRecord,
	#superclass : #DSAbstractEventRecord,
	#category : #'DebuggingSpy-Records'
}
