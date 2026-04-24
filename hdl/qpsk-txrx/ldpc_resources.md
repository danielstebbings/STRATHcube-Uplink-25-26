| Params                        | Try 1   | Try 2 | Try 3 |
| ----------------------------- | ------- | ----- | ----- |
| FEC Frame Type                | Short   | ~     | ~     |
| Code Rate                     | 1/4     | ~     | ~     |
| Parallelism                   | 180     | 45    | 45    |
| Algorithm                     | Min-Sum | ~     | ~     |
| Decoding Termination Criteria | Max     | ~     | ~     |
| Number of Iterations          | 4       | ~     | 1     |
|                               |         |       |       |
|                               |         |       |       |

Try 1:

| Multipliers             |   0   |
| :---------------------- | :---: |
| Adders/Subtractors      | 1138 |
| Registers               | 4682 |
| Total 1-Bit Registers   | 34980 |
| RAMs                    |  545  |
| Multiplexers            | 4786 |
| I/O Bits                |  20  |
| Static Shift operators  |  181  |
| Dynamic Shift operators |   0   |

Try 2:

| Multipliers             |  0  |
| :---------------------- | :--: |
| Adders/Subtractors      | 291 |
| Registers               | 1225 |
| Total 1-Bit Registers   | 8256 |
| RAMs                    | 229 |
| Multiplexers            | 1169 |
| I/O Bits                |  20  |
| Static Shift operators  |  3  |
| Dynamic Shift operators |  0  |

Try 3:

| Multipliers             |  0  |
| :---------------------- | :--: |
| Adders/Subtractors      | 291 |
| Registers               | 1225 |
| Total 1-Bit Registers   | 8256 |
| RAMs                    | 229 |
| Multiplexers            | 1169 |
| I/O Bits                |  20  |
| Static Shift operators  |  3  |
| Dynamic Shift operators |  0  |
