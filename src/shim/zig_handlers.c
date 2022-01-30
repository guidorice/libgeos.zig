#include <stdio.h>
#include <stdarg.h>
#include <stdlib.h>

int max_msg_size = 1024;

// extern handlers which are exported by default_handlers.zig.
// zig_handlers.h for usage info.
extern void noticeHandler(const char *msg);
extern void errorHandler(const char *msg);

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
