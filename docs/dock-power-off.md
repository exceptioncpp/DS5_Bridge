# Charging-dock automatic power-off (DualSense / DualSense Edge)

The firmware uses the dedicated `DockDetect` flag in a normal Bluetooth
0x31 input report (USB-shaped payload byte 53, bit 6; raw BT byte 56).
This is **not** equivalent to the battery charging state or USB-C power.

- Default: **enabled**. After 2 seconds of continuous DockDetect (with
  input reports spaced at most 750 ms apart), the bridge sends the actual
  controller's Bluetooth power-off feature report (0x08, value 0x02).
- The detector resets on dock removal, a stale input stream, Bluetooth
  disconnection, or if the opt-out is set. It emits at most one shutdown
  request for each continuous dock.
- Companion: **Settings → Connection & Power → Disable power off on dock**.
  Enable the switch to prevent automatic shutdown.
- The opt-out is saved by **Companion on the PC** and reapplied when it
  reconnects to the bridge, consistent with existing Companion settings.
  The controller normally powers off **without Companion running**.
  After a Pico reboot with Companion closed, the default enabled behavior
  resumes until Companion reconnects. This setting is NOT stored in RP2350
  flash.
- A third-party cradle must actually assert DockDetect. Charging status
  alone cannot establish that the controller is in a dock.

## Test with Waveshare RP2350B-Plus-W
1. Open Actions for this PR and download the successful Build firmware artifact
   `ds5-bridge-companion-waveshare.uf2`. Keep the previous UF2 for rollback.
2. Flash the Waveshare board with BOOTSEL and connect Edge as before.
3. With the powered **contact cradle**, place Edge inside. After about 2
   seconds the controller should power off, preserving Bluetooth pairing.
4. Lift Edge, press PS, verify reconnection.
5. To test the opt-out, run **Companion built from this PR** (the Companion
   checks workflow builds the app, or use the repo's documented build process).
   Enable `Disable power off on dock`, then place Edge in the cradle again:
   it must stay on.
6. Turn the opt-out back off to restore auto power-off.

The original awalol/DS5Dongle disconnects the Bluetooth link on docking.
This fork uses `bt_power_off_controller()` instead to prevent automatic
reconnection while still docked.
