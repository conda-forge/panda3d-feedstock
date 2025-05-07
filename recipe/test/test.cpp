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

  // Check linkage errors on win32 when linking with clang-cl this executable
  // using a panda3d conda package built with MSVC
  GraphicsOutput *windowOutput = window->get_graphics_output();
  GraphicsStateGuardian* gsg = windowOutput->get_gsg();
  // this call would break linkage due to different symbols for ConfigFlags::_global_modified
  auto dummy2 = gsg->get_copy_texture_inverted();

  // Close the framework
  framework.close_framework();
  return (0);
}
