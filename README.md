<p align="center">
  <a href="https://rm-scripts.dev/">
    <img src="https://i.imgur.com/J2qiRpn.png" alt="qbx_customs — RM-SCRIPTS" width="720" />
  </a>
</p>

<h1 align="center">qbx_customs</h1>

<p align="center">
  <strong>RM-SCRIPTS</strong> · Vehicle customs for Qbox — performance, cosmetics, paints &amp; extras from a clean NUI (poly zones, drag camera, priced mods).
</p>

<p align="center">
  <a href="https://rm-scripts.dev/">Store</a>
  &nbsp;·&nbsp;
  <a href="https://rm-scripts.dev/docs">Documentation</a>
  &nbsp;·&nbsp;
  <a href="https://discord.gg/5F2ecFqmVA">Discord</a>
</p>

---

**qbx_customs** is a **Qbox** vehicle customization resource: HTML/CSS/JS NUI (**RM-CUSTOMS**), **ox_lib** zones / text UI / callbacks, and **qbx_core** payments. Mods persist to **`player_vehicles`** via **oxmysql**. Includes Gen9 paint meta, chameleon colours, neon, wheels, and a free-orbit drag camera.

## Requirements

- **[ox_lib](https://github.com/communityox/ox_lib)** — shared `@ox_lib/init.lua` provides `lib` and `cache`. Start **ox_lib** before **qbx_customs**.
- **[qbx_core](https://github.com/Qbox-project/qbx_core)** — player money, notify, and `@qbx_core/modules/playerdata.lua` / `lib.lua`.
- **[oxmysql](https://github.com/overextended/oxmysql)** — saves owned vehicle props (`UPDATE player_vehicles`).

## Installation

1. Place `qbx_customs` in your resources folder.
2. Ensure **ox_lib**, **oxmysql**, and **qbx_core** are installed and started.
3. Add to `server.cfg` (order matters):

   ```cfg
   ensure ox_lib
   ensure oxmysql
   ensure qbx_core
   ensure qbx_customs
   ```

4. Edit zones and prices in `config/shared.lua`, and mod / paint lists in `config/client.lua`.

## Configuration

### `config/shared.lua`

| Option | Description |
|--------|-------------|
| `zones` | Poly zone list: `points` (`vec3`), optional `blip`, `hideBlip`, `job`, `freeRepair`, `freeMods`, `allowedClasses`, `deniedClasses`, `modelBlacklist` |
| `prices.cosmetic` | Flat price for cosmetic / parts mods |
| `prices.colors` | Flat price for paint, neon, xenon, tyre smoke, etc. |
| `prices[11]` … `prices[15]` | Per-level prices for engine, brakes, transmission, suspension |
| `prices[18]` | Turbo price |

Keep **Z** values consistent on each zone’s `points` — mismatched heights break poly zones.

### Zone options (per entry)

| Field | Description |
|-------|-------------|
| `job` | Job names allowed to use the shop (omit = everyone) |
| `freeRepair` | Jobs that repair for free |
| `freeMods` | Jobs that install mods for free |
| `allowedClasses` / `deniedClasses` | Vehicle class filters |
| `modelBlacklist` | Denied vehicle model hashes |
| `blip` | `sprite`, `color`, `scale`, `label` |

### `config/client.lua`

| Option | Description |
|--------|-------------|
| `currency` | Price prefix shown in the NUI (e.g. `$`) |
| `mods` | Mod kit entries: `id`, `label`, `category` (`parts` / `performance`); set `enabled = false` to hide |
| `paints` | Classic / Matte / Metal / Worn / Chameleon colour tables |
| `modLabels` | Display names for performance / horn levels |
| `xenon`, `windowTints`, `plateIndexes`, `neon`, `neonColors`, `tyreSmoke`, `wheels` | Extra cosmetic lists |

## Client exports

| Export | Returns | Description |
|--------|---------|-------------|
| `OpenMenu` | `boolean` | Opens customs for the current vehicle (`cache.vehicle`). Skips zone payment when opened this way. Returns `false` if not in a vehicle or already open. |

### Example

```lua
local opened = exports['qbx_customs']:OpenMenu()
if not opened then
    -- not in a vehicle, or menu already open
end
```

## ox_lib

- **`lib.zones.poly`** — customs shops from `config/shared.lua` `points`
- **`lib.showTextUI` / `lib.hideTextUI`** — press **E** prompt while in a zone vehicle
- **`lib.onCache('vehicle', …)`** — hide UI / re-check access when leaving the vehicle
- **`lib.callback`** — pay, repair, zone index, and vehicle props between client and server
- **`lib.getVehicleProperties`** — props saved on menu close for owned plates

---

© RM-SCRIPTS
