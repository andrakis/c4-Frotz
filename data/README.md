# Frotz's stories

Frotz is the interpreter; the games are Z-machine story files. Microsoft
released Zork I, II and III under the MIT licence in 2025, and each one's
repository has its compiled story:

| story | repository | file |
|---|---|---|
| `zork1.z3` | [historicalsource/zork1](https://github.com/historicalsource/zork1) | `COMPILED/zork1.z3` |
| `zork2.z3` | [historicalsource/zork2](https://github.com/historicalsource/zork2) | `COMPILED/zork2.z3` |
| `zork3.z3` | [historicalsource/zork3](https://github.com/historicalsource/zork3) | `COMPILED/zork3.z3` |

No game's data is committed (games/README.md in c4), so `make frotz-data`
fetches these from a fixed commit and checks each one's SHA-256. To use your
own copy, name it with `ZORK1_Z3`, `ZORK2_Z3` or `ZORK3_Z3`.

The licence covers the Zork repositories' contents, not the Zork trademark.
