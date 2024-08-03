## Bluetooth

The thermometer exposes a device called `BBQ ProbeE xxxxx` where the last part
contains a series of digits identifying the device.

It exposes the following device information (`180A`):

- Manufacturer Name String (`FMG`)
- Model number String (`BBQ ProbeE`)
- Serial Number String
- Firmware Revision String (e.g. `AP0.16`)

It also exposes a service called `FB00` with the following characteristics:

- `FB01` - The name of the device (`BBQ ProbeE xxxxx`)
- `FB02` - Temperature events (e.g. `FFFF6C028A020C`, `FFFF940294020C`, `FFFFC60280020C`, `FFFFA802B2020C`, `FFFFA802A8020C`, `FFFF8A02C6020C`)
  - Byte 1 contains the battery status
  - Byte 2 contains the "work status"
    1. Type of meat + target temperature
    2. Time
    3. Temperature
  - Bytes 3 and 4 contain the temperature (i.e. `028A` -> 650. 650 / 10 - 40 = 25°c)
  - Hex:  80029E020C
  - Byte 5 contains the "type"
- `FB03` - Write service. Used to write target temperature,
  - `10` (status == 1): Save temperature
  - `11` (stauts == 2): `11028A00` - set timer to `028A` seconds?
  - `12` (status == 3): `12028A00` - save temperature `028A`?
  - `13`: `13000000` - stop work
  -
- `FB04` - Unknown. Response to write?
- `FB05` - Status events (e.g. `0300000000FF`, `0301000000FF`, `030002AF01FF`)
  - Byte 1 - battery low warning bool 1/0

Notes:

- There seems to be some sort of mesh where probes broadcast other probes' data?


Hex:  0294020C

0. beef
1. veal
2. lamb
3. venison
4. pork
5. chicken
6. duck
7. fish
8. hamburger

Difference: "grill temp":
Peripheral: BBQ ProbeE 31655 didUpdateValueFor: FB02 to: FFFF800294020C
Peripheral: BBQ ProbeE 31655 didUpdateValueFor: FB02 to: FFFF8002BC020C

Difference: "probe temp":
al: BBQ ProbeE 31655 didUpdateValueFor: FB02 to: FFFF8002C6020C
Peripheral: BBQ ProbeE 31655 didUpdateValueFor: FB02 to: FFFF8A02BC020C
Peripheral: BBQ ProbeE 31655 didUpdateValueFor: FB02 to: FFFFC602BC020C

NOTE: Little endian! So 8a02 -> 028a AKA FF FF, probe temp, grill temp, ??

So byte orders above are wrong - it's "broadcastUpdate" we should be looking at?

NOTE: One time (without any write changes; I think when setting the probe to
the timer mode), the app started crashing when it was connected to. Writing the
"stop work command" worked and made it work again.

## Resources

- <https://punchthrough.com/core-bluetooth-basics/>
