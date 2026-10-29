# Setup Script for Nothing Phone 2 (Pong)

Custom ROM trees and dependency setup script for **Nothing Phone 2 (Pong)**.

## How to Run

Execute from the root directory of your ROM source tree:

```bash
bash <(curl -sSL https://raw.githubusercontent.com/Butterfingerss/pong_setup/main/setup.sh)
```

Or clone the repository and run:

```bash
git clone https://github.com/Butterfingerss/pong_setup.git
bash pong_setup/setup.sh
```

## Included Repositories

- `device/nothing/Pong` (`17`)
- `vendor/nothing/Pong` (`17`)
- `vendor/nothing/camera` (`calcite-phone2`)
- `vendor/qcom/opensource/interfaces` (`lineage-24.0`)
- `kernel/nothing/sm8475` (`17`)
- `kernel/nothing/sm8475-modules` (`17`)
- `kernel/nothing/sm8475-devicetrees` (`lineage-23.0`)
- `hardware/qcom-caf/sm8450/display` (`16`)
- `hardware/dolby` (`16`)
- `packages/apps/ParanoidGlyphPhone2` (`17`)
- `packages/apps/GlyphAdapter` (`16`)
