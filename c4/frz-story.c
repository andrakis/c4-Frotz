// frz-story.c -- which story a program with none named plays. zork1, zork2
// and zork3 on C4IX's PATH are frotz under other names (c4ix.vfs.txt), and
// frotz alone means Zork I. Beside the program first, then where C4IX keeps them.
#include <stdio.h>
#include <string.h>
#include <ctype.h>

static char frz_path[64];

static int frz_there(char *p) {
    FILE *f;
    f = fopen(p, "rb");
    if (!f) return 0;
    fclose(f);
    return 1;
}

char *frz_story(char *prog) {
    char name[16];
    char *p;
    int n;
    p = strrchr(prog, '/');
    if (p) prog = p + 1;
    n = 0;
    while (prog[n] && prog[n] != '.' && n < 15) { name[n] = tolower(prog[n]); ++n; }
    name[n] = 0;
    if (strncmp(name, "zork", 4) != 0) strcpy(name, "zork1");
    sprintf(frz_path, "%s.z3", name);
    if (frz_there(frz_path)) return frz_path;
    sprintf(frz_path, "/usr/games/frotz/data/%s.z3", name);
    if (frz_there(frz_path)) return frz_path;
    return 0;
}
