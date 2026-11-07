// defs.h -- what upstream's Makefile generates in src/common: its defaults,
// with Blorb and sound left out, as the dumb interface can do without both.
#ifndef COMMON_DEFINES_H
#define COMMON_DEFINES_H
#define VERSION "2.56pre"
#define RELEASE_NOTES "c4"
#define MAX_UNDO_SLOTS 500
#define MAX_FILE_NAME 80
#define TEXT_BUFFER_SIZE 275
#define INPUT_BUFFER_SIZE 200
#define STACK_SIZE 32768
#define NO_BLORB
#define NO_SOUND
#endif
