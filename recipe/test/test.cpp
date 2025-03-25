// Include all the stuff
#include <panda3d/pandaFramework.h>
#include <panda3d/pandaSystem.h>

int main(int argc, char *argv[]) {
  // Open the framework
  PandaFramework framework;
  framework.open_framework(argc, argv);
  // Set a nice title
  framework.set_window_title("Hello World!");
  // Open it!
  WindowFramework *window = framework.open_window();

  // Check whether the window is loaded correctly
  if (window != nullptr) {
    nout << "Opened the window successfully!\n";

    window->enable_keyboard(); // Enable keyboard detection
    window->setup_trackball(); // Enable default camera movement

    // Put here your own code, such as the loading of your models

    // Do the main loop
    framework.main_loop();
  } else {
    nout << "Could not load the window!\n";
  }
  // Close the framework
  framework.close_framework();
  return (0);
}
