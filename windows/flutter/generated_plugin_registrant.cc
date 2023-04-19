//
//  Generated file. Do not edit.
//

// clang-format off

#include "generated_plugin_registrant.h"

#include <pdfx/pdfx_plugin.h>
#include <screen_brightness_windows/screen_brightness_windows_plugin.h>

void RegisterPlugins(flutter::PluginRegistry* registry) {
  PdfxPluginRegisterWithRegistrar(
      registry->GetRegistrarForPlugin("PdfxPlugin"));
  ScreenBrightnessWindowsPluginRegisterWithRegistrar(
      registry->GetRegistrarForPlugin("ScreenBrightnessWindowsPlugin"));
}
