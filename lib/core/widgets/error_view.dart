import 'package:flutter/material.dart';
import 'package:forest_breweries/core/error/app_exception.dart';

extension AppExceptionMessage on AppException {
  String get userMessage => switch (this) {
    NetworkException() => 'Check your internet connection and try again.',
    NotFoundException() => "We couldn't find what you were looking for.",
    ServerException() => 'The server is having trouble. Try again later.',
    UnexpectedException() => 'Something went wrong. Please try again.',
  };
}

class ErrorView extends StatelessWidget {
  const ErrorView({required this.error, required this.onRetry, super.key});

  final AppException error;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline, size: 48),
            const SizedBox(height: 16),
            Text(error.userMessage, textAlign: TextAlign.center),
            const SizedBox(height: 16),
            FilledButton(onPressed: onRetry, child: const Text('Retry')),
          ],
        ),
      ),
    );
  }
}
