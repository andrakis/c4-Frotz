# c4-images.sh c4ix|bare -- Frotz's part of c4's build-images.sh, which
# sources it from c4's root (games/README.md in c4)
GAMEDIR=games/frotz
case "$1" in
c4ix)
    # linked against C4IX's libc, with the stories in the disk's frotz/,
    # lazy (c4ix.vfs.txt: /usr/games/frotz/data). zork1, zork2 and zork3 are
    # frotz under other names, and play the story their name says.
    rm -rf $DISK/frotz
    if ls .frotz/*.c4o > /dev/null 2>&1 && [ -f $PB/lib/libc.c4s ]; then
        say "linking Frotz for C4IX"
        ./c4rlink32 .frotz/*.c4o -l $PB/lib/libc.c4s -o $DISK/c4ix-frotz.c4r > /dev/null
        mkdir -p $DISK/frotz
        for s in zork1 zork2 zork3; do
            if [ -f $GAMEDIR/data/$s.z3 ]; then cp $GAMEDIR/data/$s.z3 $DISK/frotz/; fi
        done
    fi ;;
bare)
    if ls .frotz/*.c4o > /dev/null 2>&1; then
        item frotz
        ./c4rlink32 .frotz/*.c4o .libc-bare/libc-*.c4o -o $GAMESDISK/frotz.c4r > /dev/null
        for s in zork1 zork2 zork3; do
            if [ -f $GAMEDIR/data/$s.z3 ]; then cp $GAMEDIR/data/$s.z3 $GAMESDISK/; fi
        done
        GAMES_ON_DISK="$GAMES_ON_DISK FROTZ"
    fi ;;
esac
