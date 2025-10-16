// Re-export the platform-specific implementation using a conditional export.
// This file intentionally contains no declarations so the selected
// implementation's top-level functions are available to callers who import
// `package:gymwingapp/zacc_binding.dart`.
export 'zacc_binding_stub.dart'
    if (dart.library.ffi) 'zacc_binding_native.dart'
    if (dart.library.js) 'zacc_binding_web.dart';
