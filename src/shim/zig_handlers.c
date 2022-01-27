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

extern void notice_handler(const char *msg);
extern void error_handler(const char *msg);

/// notice_handler owns the generated string.
void shim_notice(const char *fmt, ...)
{
    char *msg;
    if ((msg = malloc(max_msg_size)) == NULL)
        return;
    va_list ap;
    va_start(ap, fmt);
    vsnprintf(msg, max_msg_size, fmt, ap);
    va_end(ap);
    notice_handler(msg);
    return;
}

// log_and_exit_handler() owns the generated string.
void shim_error(const char *fmt, ...)
{
    char *msg;
    if ((msg = malloc(max_msg_size)) == NULL)
        return;
    va_list ap;
    va_start(ap, fmt);
    vsnprintf(msg, max_msg_size, fmt, ap);
    va_end(ap);
    error_handler(msg);
    return;
}
