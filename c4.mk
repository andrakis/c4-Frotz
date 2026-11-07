# c4.mk -- this game's part of c4's Makefile. c4 includes it from
# games/frotz/c4.mk, its submodule, and runs it from c4's root, with c4's
# tools and variables (games/README.md in c4). Without it, c4 builds
# everything else, and test-frotz says it was skipped.

# Frotz's dumb interface (src/dumb), which reads lines and prints text, so
# it plays in a Terminal. Its units with c4lc, the same objects for C4IX,
# the bare machine and C4DOS. Upstream's Makefile generates defs.h and
# hash.h; here they are c4/defs.h and c4/hash.h. No Blorb, no sound. The
# stories are data, not in the repository (data/README.md).
FRZ        := games/frotz
FRZ_COMMON := buffer err fastmem files getopt hotkey input main math missing object \
              process quetzal random redirect screen sound stream table text variable
FRZ_DUMB   := dinit dinput doutput dpic
FRZ_HDRS   := $(wildcard $(FRZ)/src/common/*.h $(FRZ)/src/dumb/*.h $(FRZ)/c4/*.h $(FRZ)/c4/sys/*.h) \
              $(wildcard src/c4ix/libc/include/*.h src/c4ix/libc/include/sys/*.h)
FRZ_CC     := ./c4sp32 -c 400000 src/c4sp/lisp/c4lc.lisp -O $(IMG_G) -mfuse -fno-builtin -c -conforming \
              -D C4FRZ -D NO_BASENAME -I $(FRZ)/c4 -I src/c4ix/libc/include \
              -I $(FRZ)/src/common -I $(FRZ)/src/dumb
frotz-objs: $(FRZ_COMMON:%=.frotz/%.c4o) $(FRZ_DUMB:%=.frotz/%.c4o) .frotz/frz-story.c4o
.frotz/%.c4o: $(FRZ)/src/common/%.c $(FRZ_HDRS) $(C4LC_LISP) .img_g | c4sp32
	@mkdir -p .frotz
	$(FRZ_CC) $< $@ > /dev/null
.frotz/%.c4o: $(FRZ)/src/dumb/%.c $(FRZ_HDRS) $(C4LC_LISP) .img_g | c4sp32
	@mkdir -p .frotz
	$(FRZ_CC) $< $@ > /dev/null
.frotz/%.c4o: $(FRZ)/c4/%.c $(FRZ_HDRS) $(C4LC_LISP) .img_g | c4sp32
	@mkdir -p .frotz
	$(FRZ_CC) $< $@ > /dev/null
GAME_OBJS += frotz-objs
PHONY += frotz-objs frotz-data

# ... and by gcc for the host, the reference test-frotz holds the c4lc build
# to; 32-bit, as that is. Its own libc's headers come first: c4/ only has
# to give it defs.h and hash.h.
FRZ_HOST_SRCS := $(FRZ_COMMON:%=$(FRZ)/src/common/%.c) $(FRZ_DUMB:%=$(FRZ)/src/dumb/%.c) $(FRZ)/c4/frz-story.c
frotz-host: $(FRZ_HOST_SRCS) $(FRZ_HDRS)
	gcc -m32 -O2 -std=gnu99 -w -DC4FRZ -DNO_BASENAME -idirafter $(FRZ)/c4 -I$(FRZ)/src/common -I$(FRZ)/src/dumb -o $@ $(FRZ_HOST_SRCS)

# The stories: Zork I, II and III as Microsoft released them in 2025, under
# the MIT licence, from each one's repository at a fixed commit, checked by
# SHA-256 (data/README.md). No game's data is committed, whatever its licence.
FRZ_RAW := https://raw.githubusercontent.com/historicalsource
$(FRZ)/data/zork1.z3:
	sh games/fetch.sh $@ 37084966477dff679282de42974b2077156b1bd68fad92a65d4ea94d8eb64d79 ZORK1_Z3 \
	  $(FRZ_RAW)/zork1/97b7b3d68c075dd9af7da499c3e9690ada3471fd/COMPILED/zork1.z3
$(FRZ)/data/zork2.z3:
	sh games/fetch.sh $@ 3ae7d5558943e9721f3e4b273c8a7faec1a03a604e1ae4ee1cde472c21cb24ac ZORK2_Z3 \
	  $(FRZ_RAW)/zork2/3da9661098809788a99cef00f00c865c6c204f96/COMPILED/zork2.z3
$(FRZ)/data/zork3.z3:
	sh games/fetch.sh $@ b637a242865d059890184164ce8dec28554cc80901dcbf26c740b2d1ed0d4eb8 ZORK3_Z3 \
	  $(FRZ_RAW)/zork3/3ec9ed412b5f3cafe65d83c727d07db1fe4a86a8/COMPILED/zork3.z3
frotz-data: $(FRZ)/data/zork1.z3 $(FRZ)/data/zork2.z3 $(FRZ)/data/zork3.z3

# test-frotz: a walk through Zork I on a fixed seed (c4/walk.txt), by gcc and
# by c4lc -- on the bare machine, under C4DOS and inside C4IX -- must print
# the same game, from its banner to its last line. Then c4/save.txt saves and
# restores inside C4IX, the one of the three with a disk to write on. Only
# where the stories are; skipped, and saying so, where they are not.
FRZ_OPTS := -m -p -q -s 42 -w 80 -h 24
FRZ_FILT := awk '/^ZORK I: The Great/{p=1} p' | tr -d '\r' | sed -e 's/^>//' -e 's,[^ ]*/zork1.,zork1.,'
test-frotz: frotz-host c4bb-images
	@if [ ! -f src/c4bb/images/games/zork1.z3 ]; then \
	   echo "test-frotz: skipped, no stories (games/frotz/data/README.md)"; exit 0; fi; \
	 rm -rf .frz_t && mkdir -p .frz_t && \
	 ./frotz-host $(FRZ_OPTS) $(FRZ)/data/zork1.z3 < $(FRZ)/c4/walk.txt 2>/dev/null \
	   | $(FRZ_FILT) | sed '$$d' > .frz_t/host.txt && \
	 ( cd src/c4bb/images/games && { timeout 1200 node ../../../../libjs/cli.js -m 64 -d . frotz.c4r $(FRZ_OPTS) zork1.z3 \
	     < ../../../../$(FRZ)/c4/walk.txt > ../../../../.frz_t/bare.out 2>/dev/null & \
	   { printf 'frotz $(FRZ_OPTS) zork1.z3\n'; cat ../../../../$(FRZ)/c4/walk.txt; printf 'ver\n'; } \
	     | timeout 1200 node ../../../../libjs/cli.js -m 64 -d . ../c4dos32.c4r \
	     > ../../../../.frz_t/dos.out 2>/dev/null; wait; } ) && \
	 { printf 'frotz $(FRZ_OPTS) /usr/games/frotz/data/zork1.z3\n'; cat $(FRZ)/c4/walk.txt; printf 'exit\n'; } \
	   | timeout 1200 node libjs/cli.js -m 64 -d src/c4bb/images/disk src/c4bb/images/c4ix32.c4r \
	   2>/dev/null > .frz_t/c4ix.out && \
	 n=$$(wc -l < .frz_t/host.txt) && \
	 for w in bare dos c4ix; do cat .frz_t/$$w.out | $(FRZ_FILT) | head -n $$n | cmp -s .frz_t/host.txt - \
	   || { echo "test-frotz: $$w's game differs:"; cat .frz_t/$$w.out | $(FRZ_FILT) | head -n $$n | diff .frz_t/host.txt - | head -20; exit 1; }; done && \
	 ( cd .frz_t && ../frotz-host $(FRZ_OPTS) ../$(FRZ)/data/zork1.z3 < ../$(FRZ)/c4/save.txt 2>/dev/null ) \
	   | $(FRZ_FILT) | sed '$$d' > .frz_t/host2.txt && \
	 { printf 'cd /tmp\nfrotz $(FRZ_OPTS) /usr/games/frotz/data/zork1.z3\n'; cat $(FRZ)/c4/save.txt; printf 'exit\n'; } \
	   | timeout 1200 node libjs/cli.js -m 64 -d src/c4bb/images/disk src/c4bb/images/c4ix32.c4r \
	   2>/dev/null > .frz_t/c4ix2.out && \
	 n=$$(wc -l < .frz_t/host2.txt) && \
	 { cat .frz_t/c4ix2.out | $(FRZ_FILT) | head -n $$n \
	     | cmp -s .frz_t/host2.txt - \
	   || { echo "test-frotz: saving and restoring differs:"; cat .frz_t/c4ix2.out | $(FRZ_FILT) | head -n $$n | diff .frz_t/host2.txt - | head -20; exit 1; }; } && \
	 rm -rf .frz_t && echo "test-frotz: OK"
GAME_TESTS += test-frotz
PHONY += test-frotz
