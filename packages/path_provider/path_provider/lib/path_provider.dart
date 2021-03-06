// Copyright 2019 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:async';
import 'dart:io' show Directory, Platform;

import 'package:flutter/foundation.dart' show kIsWeb, visibleForTesting;
import 'package:path_provider_linux/path_provider_linux.dart';
import 'package:path_provider_platform_interface/path_provider_platform_interface.dart';

export 'package:path_provider_platform_interface/path_provider_platform_interface.dart'
    show StorageDirectory;

/// Disables platform override in order to use a manually registered [PathProviderPlatform], only for testing right now
///
/// Make sure to disable the override before using any of the `path_provider` methods
/// To use your own [PathProviderPlatform], make sure to include the following lines
/// ```
/// PathProviderPlatform.instance = YourPathProviderPlatform();
/// disablePathProviderPlatformOverride = true;
/// // Use the `path_provider` methods:
/// final dir = await getTemporaryDirectory();
/// ```
/// See this issue https://github.com/flutter/flutter/issues/52267 for why this is required
@visibleForTesting
set disablePathProviderPlatformOverride(bool override) {
  _disablePlatformOverride = override;
}

bool _disablePlatformOverride = false;
PathProviderPlatform __platform;

// This is to manually endorse the linux path provider until automatic registration of dart plugins is implemented.
// See this issue https://github.com/flutter/flutter/issues/52267 for details
PathProviderPlatform get _platform {
  if (__platform != null) {
    return __platform;
  }
  if (!kIsWeb && Platform.isLinux && !_disablePlatformOverride) {
    __platform = PathProviderLinux();
  } else {
    __platform = PathProviderPlatform.instance;
  }
  return __platform;
}

/// Path to the temporary directory on the device that is not backed up and is
/// suitable for storing caches of downloaded files.
///
/// Files in this directory may be cleared at any time. This does *not* return
/// a new temporary directory. Instead, the caller is responsible for creating
/// (and cleaning up) files or directories within this directory. This
/// directory is scoped to the calling application.
///
/// On iOS, this uses the `NSCachesDirectory` API.
///
/// On Android, this uses the `getCacheDir` API on the context.
Future<Directory> getTemporaryDirectory() async {
  final String path = await _platform.getTemporaryPath();
  if (path == null) {
    return null;
  }
  return Directory(path);
}

/// Path to a directory where the application may place application support
/// files.
///
/// Use this for files you don???t want exposed to the user. Your app should not
/// use this directory for user data files.
///
/// On iOS, this uses the `NSApplicationSupportDirectory` API.
/// If this directory does not exist, it is created automatically.
///
/// On Android, this function uses the `getFilesDir` API on the context.
Future<Directory> getApplicationSupportDirectory() async {
  final String path = await _platform.getApplicationSupportPath();
  if (path == null) {
    return null;
  }

  return Directory(path);
}

/// Path to the directory where application can store files that are persistent,
/// backed up, and not visible to the user, such as sqlite.db.
///
/// On Android, this function throws an [UnsupportedError] as no equivalent
/// path exists.
Future<Directory> getLibraryDirectory() async {
  final String path = await _platform.getLibraryPath();
  if (path == null) {
    return null;
  }
  return Directory(path);
}

/// Path to a directory where the application may place data that is
/// user-generated, or that cannot otherwise be recreated by your application.
///
/// On iOS, this uses the `NSDocumentDirectory` API. Consider using
/// [getApplicationSupportDirectory] instead if the data is not user-generated.
///
/// On Android, this uses the `getDataDirectory` API on the context. Consider
/// using [getExternalStorageDirectory] instead if data is intended to be visible
/// to the user.
Future<Directory> getApplicationDocumentsDirectory() async {
  final String path = await _platform.getApplicationDocumentsPath();
  if (path == null) {
    return null;
  }
  return Directory(path);
}

/// Path to a directory where the application may access top level storage.
/// The current operating system should be determined before issuing this
/// function call, as this functionality is only available on Android.
///
/// On iOS, this function throws an [UnsupportedError] as it is not possible
/// to access outside the app's sandbox.
///
/// On Android this uses the `getExternalFilesDir(null)`.
Future<Directory> getExternalStorageDirectory() async {
  final String path = await _platform.getExternalStoragePath();
  if (path == null) {
    return null;
  }
  return Directory(path);
}

/// Paths to directories where application specific external cache data can be
/// stored. These paths typically reside on external storage like separate
/// partitions or SD cards. Phones may have multiple storage directories
/// available.
///
/// The current operating system should be determined before issuing this
/// function call, as this functionality is only available on Android.
///
/// On iOS, this function throws an UnsupportedError as it is not possible
/// to access outside the app's sandbox.
///
/// On Android this returns Context.getExternalCacheDirs() or
/// Context.getExternalCacheDir() on API levels below 19.
Future<List<Directory>> getExternalCacheDirectories() async {
  final List<String> paths = await _platform.getExternalCachePaths();

  return paths.map((String path) => Directory(path)).toList();
}

/// Paths to directories where application specific data can be stored.
/// These paths typically reside on external storage like separate partitions
/// or SD cards. Phones may have multiple storage directories available.
///
/// The current operating system should be determined before issuing this
/// function call, as this functionality is only available on Android.
///
/// On iOS, this function throws an UnsupportedError as it is not possible
/// to access outside the app's sandbox.
///
/// On Android this returns Context.getExternalFilesDirs(String type) or
/// Context.getExternalFilesDir(String type) on API levels below 19.
Future<List<Directory>> getExternalStorageDirectories({
  /// Optional parameter. See [StorageDirectory] for more informations on
  /// how this type translates to Android storage directories.
  StorageDirectory type,
}) async {
  final List<String> paths =
      await _platform.getExternalStoragePaths(type: type);

  return paths.map((String path) => Directory(path)).toList();
}

/// Path to the directory where downloaded files can be stored.
/// This is typically only relevant on desktop operating systems.
///
/// On Android and on iOS, this function throws an [UnsupportedError] as no equivalent
/// path exists.
Future<Directory> getDownloadsDirectory() async {
  final String path = await _platform.getDownloadsPath();
  if (path == null) {
    return null;
  }
  return Directory(path);
}
