w = Window.new; // new window
w.front; // make it constantly in front
w.alwaysOnTop_(true) // exactly what you think...
w.close; // perenantly destroys window

(
w = Window.new("gui", Rect.new(750,60, 500,200))
.front
.alwaysOnTop_(true)
)

GUI.current;  // current GUI kit


w.bounds;  // X and Y of a Window

~slider = Slider.new(w.view, Rect(20, 20, 150, 30));  // a nice slider
~slider.bounds_(Rect.new(40,40, 200, 20));  // resize and move the slider

~slider.parent; // parent of a child, like a slider

w.view.children; // children of a window;


(
w = Window.new("gui", Rect.new(750,60, 500,200))
.front
.alwaysOnTop_(true)

~slider = Slider.new(w.view, Rect(20, 20, 150, 30));  // a nice slider

(~slider.action_({
	arg obj;
	obj.value.postln;
});
)
~slider.background_(Color(1,0.5,0,0.5));
)

~slider.value_(0.25); // move slider programatically
~slider.valueAction_(0.25);

~slider.action; // get action, nil inital

(~slider.action_({
	arg obj;
	obj.value.postln;
});
)
~slider.background_(Color(1,0.5,0,0.5));

~slider.background; // returns a color object

