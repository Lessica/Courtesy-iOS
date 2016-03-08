PMAudioRecorderViewController
=============================

Drop-in class to record audio note in iOS application and get it back in the app. 

Usage
-----

Instalation: 

    pod 'PMAudioRecorderViewController'

or drop the contents of `AudioNoteRecorderViewController` directory in your XCode project.

In the code:

    #import "AudioRecorderViewController"
    ...
    [AudioNoteRecorderViewController showRecorderMasterViewController:self withFinishedBlock:^(BOOL wasRecordingTaken, NSURL *recordingURL) {
        if (wasRecordingTaken) {
            // do whatever you want with that URL to the .caf file
        }
    }];

Author
------

(C) Paweł Mączewski, kender@codingslut.com, Twitter: http://twitter.com/pawelmaczewski. 