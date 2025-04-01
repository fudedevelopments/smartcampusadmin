import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:intl/intl.dart';
import 'package:amplify_flutter/amplify_flutter.dart';
import 'package:amplify_storage_s3/amplify_storage_s3.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:io';
import 'dart:async';

class MonthlyReportPage extends StatefulWidget {
  const MonthlyReportPage({super.key});

  @override
  State<MonthlyReportPage> createState() => _MonthlyReportPageState();
}

class _MonthlyReportPageState extends State<MonthlyReportPage> {
  final Dio _dio = Dio();
  int _selectedMonth = DateTime.now().month;
  int _selectedYear = DateTime.now().year;
  bool _isGenerating = false;
  bool _isDownloading = false;
  String? _csvFilePath;
  String? _errorMessage;
  String? _downloadLocation;

  // Keep track of dialog status
  bool _isDialogOpen = false;

  @override
  void dispose() {
    // Ensure any open dialogs are closed when widget is disposed
    _closeProgressDialog();
    super.dispose();
  }

  // Safe method to close any open dialog
  void _closeProgressDialog() {
    if (_isDialogOpen &&
        mounted &&
        Navigator.of(context, rootNavigator: true).canPop()) {
      try {
        Navigator.of(context, rootNavigator: true).pop();
        _isDialogOpen = false;
      } catch (e) {
        safePrint('Error closing dialog: $e');
      }
    }
  }

  Future<void> _generateCsvReport() async {
    setState(() {
      _isGenerating = true;
      _errorMessage = null;
      _csvFilePath = null;
    });

    try {
      final response = await _dio.get(
        'https://v2hmo3c5xb5sswgdxuq2v6cdre0qnnmq.lambda-url.ap-south-1.on.aws/',
        queryParameters: {
          'month': _selectedMonth,
          'year': _selectedYear,
        },
      );

      if (response.statusCode == 200 && response.data['file_path'] != null) {
        if (mounted) {
          setState(() {
            _csvFilePath = response.data['file_path'];
            _isGenerating = false;
          });
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('CSV report generated successfully')),
          );
        }
      } else {
        throw Exception('Failed to generate CSV report');
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = e.toString();
          _isGenerating = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $_errorMessage')),
        );
      }
    }
  }

  Future<void> _downloadCsvReport() async {
    if (_csvFilePath == null) return;

    // Show file picker to select download location
    final String? outputDir = await _selectDownloadLocation();
    if (outputDir == null || !mounted) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Download cancelled')),
        );
      }
      return;
    }

    // Create a completer to track the download operation
    final downloadCompleter = Completer<void>();

    if (mounted) {
      setState(() {
        _isDownloading = true;
        _errorMessage = null;
        _downloadLocation = outputDir;
      });
    } else {
      return; // Exit if widget is no longer mounted
    }

    // Create a ValueNotifier for the download progress
    final ValueNotifier<double> progressNotifier = ValueNotifier<double>(0.0);

    // Show the progress dialog safely
    if (mounted) {
      _isDialogOpen = true;
      _showDownloadProgressDialog(context, progressNotifier, downloadCompleter);
    } else {
      progressNotifier.dispose();
      return; // Exit if widget is no longer mounted
    }

    try {
      final fileName = '${_selectedYear}_${_selectedMonth}.csv';
      final localFilePath = '$outputDir${Platform.pathSeparator}$fileName';
      final localFile = AWSFile.fromPath(localFilePath);

      // Use a timer to check dialog status periodically
      Timer? dialogCheckTimer;
      dialogCheckTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
        safePrint('Checking dialog status: $_isDialogOpen');
        if (!_isDialogOpen && !downloadCompleter.isCompleted) {
          // Dialog was closed unexpectedly, cancel the operation
          downloadCompleter.complete();
          timer.cancel();
        }
      });

      try {
        final result = await Amplify.Storage.downloadFile(
          path: StoragePath.fromString(_csvFilePath!),
          localFile: localFile,
          onProgress: (progress) {
            safePrint('Progress: ${progress.fractionCompleted}');
            // Update progress value
            progressNotifier.value = progress.fractionCompleted;

            // Close dialog when complete, but don't rely on this alone
            if (progress.fractionCompleted >= 1.0) {
              if (!downloadCompleter.isCompleted) {
                downloadCompleter.complete();
              }
            }
          },
        ).result;

        // The download is complete, cancel the timer
        dialogCheckTimer.cancel();

        // Ensure download completer is completed
        if (!downloadCompleter.isCompleted) {
          downloadCompleter.complete();
        }

        // Ensure dialog is closed
        _closeProgressDialog();

        // Update UI
        if (mounted) {
          setState(() {
            _isDownloading = false;
          });

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('File downloaded to: ${result.localFile.path}'),
              duration: const Duration(seconds: 5),
              action: SnackBarAction(
                label: 'Open Folder',
                onPressed: () {
                  _openDownloadFolder(outputDir);
                },
              ),
            ),
          );
        }
      } finally {
        dialogCheckTimer.cancel();
      }
    } catch (e) {
      // Ensure download completer is completed
      if (!downloadCompleter.isCompleted) {
        downloadCompleter.complete();
      }

      // Ensure dialog is closed
      _closeProgressDialog();

      if (mounted) {
        setState(() {
          _errorMessage = e.toString();
          _isDownloading = false;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error downloading file: $_errorMessage')),
        );
      }
    } finally {
      // Always dispose the notifier
      progressNotifier.dispose();
    }
  }

  void _showDownloadProgressDialog(
      BuildContext context,
      ValueNotifier<double> progressNotifier,
      Completer<void> downloadCompleter) {
    // Use rootNavigator to ensure dialog appears above all routes
    showDialog(
      context: context,
      barrierDismissible: false,
      useRootNavigator: true,
      builder: (BuildContext dialogContext) {
        return PopScope(
          // Prevent accidental back button closing of dialog
          canPop: false,
          onPopInvoked: (didPop) {
            // This is called when user tries to pop the dialog
            if (!didPop) {
              // Do nothing, we're preventing the pop with canPop: false
            }
          },
          child: AlertDialog(
            title: const Text('Downloading CSV'),
            content: ValueListenableBuilder<double>(
              valueListenable: progressNotifier,
              builder: (context, progress, child) {
                return Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text(
                        'Please wait while the file is being downloaded...'),
                    const SizedBox(height: 20),
                    LinearProgressIndicator(value: progress),
                    const SizedBox(height: 10),
                    Text('${(progress * 100).toStringAsFixed(0)}%'),
                  ],
                );
              },
            ),
            actions: [
              TextButton(
                onPressed: () {
                  // Mark dialog as closed
                  _isDialogOpen = false;

                  // Close dialog safely
                  Navigator.of(dialogContext, rootNavigator: true).pop();

                  // Signal download operation to cancel if needed
                  if (!downloadCompleter.isCompleted) {
                    downloadCompleter.complete();
                  }

                  // Update UI state
                  if (mounted) {
                    setState(() {
                      _isDownloading = false;
                    });
                  }
                },
                child: const Text('Cancel'),
              ),
            ],
          ),
        );
      },
    ).then((_) {
      // This callback runs when the dialog is closed (either by us or externally)
      _isDialogOpen = false;
    });
  }

  Future<String?> _selectDownloadLocation() async {
    try {
      String? selectedDirectory = await FilePicker.platform.getDirectoryPath(
        dialogTitle: 'Select download location',
      );

      if (selectedDirectory != null) {
        // Verify directory is accessible and writable
        final isValid = await _verifyDirectoryAccess(selectedDirectory);
        if (!isValid) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
                content: Text('Selected folder is not accessible or writable')),
          );
          return null;
        }
      }

      return selectedDirectory;
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error selecting folder: $e')),
      );
      return null;
    }
  }

  Future<bool> _verifyDirectoryAccess(String path) async {
    try {
      final directory = Directory(path);
      // Check if directory exists
      if (!await directory.exists()) {
        return false;
      }

      // Try to create a temporary file to verify write permissions
      final tempFile =
          File('${directory.path}${Platform.pathSeparator}temp_write_test.txt');
      await tempFile.writeAsString('Write test');
      await tempFile.delete();

      return true;
    } catch (e) {
      safePrint('Directory access error: $e');
      return false;
    }
  }

  void _openDownloadFolder(String path) async {
    try {
      if (Platform.isWindows) {
        await Process.run('explorer', [path]);
      } else if (Platform.isMacOS) {
        await Process.run('open', [path]);
      } else if (Platform.isLinux) {
        await Process.run('xdg-open', [path]);
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Unable to open folder: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Card(
            elevation: 4,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Generate Monthly Reports',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 24),
                  Row(
                    children: [
                      Expanded(
                        child: _buildMonthSelector(),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: _buildYearSelector(),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  Row(
                    children: [
                      ElevatedButton.icon(
                        onPressed: _isGenerating ? null : _generateCsvReport,
                        icon: _isGenerating
                            ? Container(
                                width: 24,
                                height: 24,
                                padding: const EdgeInsets.all(2.0),
                                child: const CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              )
                            : const Icon(Icons.file_download),
                        label: Text(
                            _isGenerating ? 'Generating...' : 'Generate CSV'),
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 12,
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      ElevatedButton.icon(
                        onPressed: (_csvFilePath != null && !_isDownloading)
                            ? _downloadCsvReport
                            : null,
                        icon: _isDownloading
                            ? Container(
                                width: 24,
                                height: 24,
                                padding: const EdgeInsets.all(2.0),
                                child: const CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              )
                            : const Icon(Icons.save_alt),
                        label: Text(_isDownloading
                            ? 'Downloading...'
                            : 'Save CSV to...'),
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 12,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          if (_errorMessage != null) ...[
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.red.shade50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.red.shade200),
              ),
              child: Row(
                children: [
                  Icon(Icons.error_outline, color: Colors.red.shade700),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      _errorMessage!,
                      style: TextStyle(color: Colors.red.shade700),
                    ),
                  ),
                ],
              ),
            ),
          ],
          if (_csvFilePath != null) ...[
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.green.shade50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.green.shade200),
              ),
              child: Row(
                children: [
                  Icon(Icons.check_circle_outline,
                      color: Colors.green.shade700),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'CSV Report Generated Successfully',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.green.shade700,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'File path: $_csvFilePath',
                          style: TextStyle(color: Colors.green.shade700),
                        ),
                        if (_downloadLocation != null) ...[
                          const SizedBox(height: 4),
                          Text(
                            'Downloaded to: $_downloadLocation',
                            style: TextStyle(color: Colors.green.shade700),
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildMonthSelector() {
    return DropdownButtonFormField<int>(
      value: _selectedMonth,
      decoration: InputDecoration(
        labelText: 'Month',
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 12,
        ),
      ),
      items: List.generate(12, (index) {
        final month = index + 1;
        return DropdownMenuItem<int>(
          value: month,
          child: Text(DateFormat('MMMM').format(DateTime(2022, month))),
        );
      }),
      onChanged: (value) {
        if (value != null) {
          setState(() {
            _selectedMonth = value;
            _csvFilePath = null;
          });
        }
      },
    );
  }

  Widget _buildYearSelector() {
    final currentYear = DateTime.now().year;
    return DropdownButtonFormField<int>(
      value: _selectedYear,
      decoration: InputDecoration(
        labelText: 'Year',
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 12,
        ),
      ),
      items: List.generate(5, (index) {
        final year = currentYear - 2 + index;
        return DropdownMenuItem<int>(
          value: year,
          child: Text(year.toString()),
        );
      }),
      onChanged: (value) {
        if (value != null) {
          setState(() {
            _selectedYear = value;
            _csvFilePath = null;
          });
        }
      },
    );
  }
}
