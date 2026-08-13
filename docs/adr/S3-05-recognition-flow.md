# ADR S3-05: Cancellable recognition use case

Recognition is exposed as an application use case with progress stages and a
structured result. The OCR port is injected, cancellation is checked before
and after the long-running operation, and failures become a typed code/message
instead of an uncaught UI exception. A later controller can run this use case
off the Flutter build path and retain draft state during navigation.
