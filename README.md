# stop_watch_echo_fi

This is a basic stop watch application for the Echofi takehome interview.

High-level:
Leveraging streams, when the stop watch is active the app will listen to a stream on the `second` duration (could be changed to any duration) and will update the UI by calling setState on each new event (per second). When the stop watch is stopped this stream is cleared and the app detaches. For the lap logic, the app wraps the `Lap` button around a visibility widget, so it is only shown when the stopwatch is active. When the lap button is tapped, it adds an entry to a list linked to a ListView. This will dynamically add the entry (time) to the view. I also added a simple ScrollController which adds a nice animation to the latest row dynamically (for when the list grows larger than the viewport). When the stopwatch is stopped the list of laps is cleared. 

Given more time I would add some better data management. Given the simple data model, I believe using built-in stateful widgets is a good pattern. I would have added some repository pattern to talk to SQL lite to persist lap data and perhaps a "closed at" timestamp to easiily and efficiently recalculate elapsed time if the app is closed.



