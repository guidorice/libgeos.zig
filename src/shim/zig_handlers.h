/*
* GEOS uses varargs functions for it's notice handler and error handler.
* Zig does not support varargs functions, so we have to use C functions
* which then call back into Zig. So these shim functions accept variable args,
* format them, and call back into Zig with the formatted results.
*/

// Format the notice string, then call noticeHandler().
// noticeHandler owns the returned memory.
void shimNotice(const char *fmt, ...);

/// Format the error string, then call errorHandler.
/// errorHandler owns the returned memory.
void shimError(const char *fmt, ...);
