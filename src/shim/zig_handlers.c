/*
* GEOS uses varargs functions for it's notice handler and error handler.
* Zig does not support varargs functions, so we have to use C functions
* which then call back into Zig. So these shim functions accept variable args,
* format them, and call back into Zig with the formatted results.
*/

#include <stdio.h>
#include <stdarg.h>
#include <stdlib.h>

int max_msg_size = 1024;

// extern handlers which are exported by default_handlers.zig
extern void noticeHandler(const char *msg);
extern void errorHandler(const char *msg);

/// Format the notice string, then call noticeHandler().
/// noticeHandler owns the returned memory.
void shimNotice(const char *fmt, ...)
{
    char *msg;
    if ((msg = malloc(max_msg_size)) == NULL)
        return;
    va_list ap;
    va_start(ap, fmt);
    vsnprintf(msg, max_msg_size, fmt, ap);
    va_end(ap);
    noticeHandler(msg);
    return;
}

/// Format the error string, then call errorHandler.
/// errorHandler owns the returned memory.
void shimError(const char *fmt, ...)
{
    char *msg;
    if ((msg = malloc(max_msg_size)) == NULL)
        return;
    va_list ap;
    va_start(ap, fmt);
    vsnprintf(msg, max_msg_size, fmt, ap);
    va_end(ap);
    errorHandler(msg);
    return;
}
