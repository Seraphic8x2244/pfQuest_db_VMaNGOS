#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
WORK="$ROOT/.work"
PFQUEST="$WORK/pfQuest"
VMANGOS="$WORK/vmangos-core"
SNAPSHOT="$WORK/snapshot"

rm -rf "$WORK"
mkdir -p "$WORK" "$SNAPSHOT"

git clone --depth 1 https://github.com/brues-code/pfQuest.git "$PFQUEST"
git clone --depth 1 --branch development https://github.com/vmangos/core.git "$VMANGOS"

PFQUEST_COMMIT="$(git -C "$PFQUEST" rev-parse HEAD)"
VMANGOS_CORE_COMMIT="$(git -C "$VMANGOS" rev-parse HEAD)"

RELEASE_JSON="$(curl -fsSL https://api.github.com/repos/vmangos/core/releases/tags/db_latest)"
VMANGOS_RELEASE="$(python3 -c 'import json,sys; print(json.load(sys.stdin)["name"])' <<<"$RELEASE_JSON")"
ASSET_URL="$(python3 -c 'import json,sys; r=json.load(sys.stdin); print(next(a["browser_download_url"] for a in r["assets"] if a["name"].endswith(".zip") and "sqlite" not in a["name"]))' <<<"$RELEASE_JSON")"
ASSET_NAME="$(basename "$ASSET_URL")"
VMANGOS_SNAPSHOT="$(python3 -c 'import re,sys; m=re.search(r"db-([0-9a-f]+)\\.zip$", sys.argv[1]); print(m.group(1) if m else "unknown")' "$ASSET_NAME")"

curl -fL --retry 3 "$ASSET_URL" -o "$WORK/$ASSET_NAME"
unzip -q "$WORK/$ASSET_NAME" -d "$SNAPSHOT"

MANGOS_SQL="$(find "$SNAPSHOT" -type f -name mangos.sql -print -quit)"
if [ -z "$MANGOS_SQL" ]; then
  echo "Could not find mangos.sql in VMaNGOS snapshot." >&2
  exit 1
fi

if mariadb -e "SELECT 1" >/dev/null 2>&1; then
  DB_ADMIN=(mariadb)
else
  DB_ADMIN=(sudo mariadb)
fi

"${DB_ADMIN[@]}" <<'SQL'
DROP DATABASE IF EXISTS pfquest;
DROP DATABASE IF EXISTS vmangos;

CREATE DATABASE pfquest DEFAULT CHARACTER SET utf8 COLLATE utf8_general_ci;
CREATE DATABASE vmangos DEFAULT CHARACTER SET utf8 COLLATE utf8_general_ci;

CREATE USER IF NOT EXISTS 'mangos'@'localhost' IDENTIFIED BY 'mangos';
CREATE USER IF NOT EXISTS 'mangos'@'127.0.0.1' IDENTIFIED BY 'mangos';
ALTER USER 'mangos'@'localhost' IDENTIFIED BY 'mangos';
ALTER USER 'mangos'@'127.0.0.1' IDENTIFIED BY 'mangos';

GRANT ALL PRIVILEGES ON pfquest.* TO 'mangos'@'localhost';
GRANT ALL PRIVILEGES ON vmangos.* TO 'mangos'@'localhost';
GRANT ALL PRIVILEGES ON pfquest.* TO 'mangos'@'127.0.0.1';
GRANT ALL PRIVILEGES ON vmangos.* TO 'mangos'@'127.0.0.1';
FLUSH PRIVILEGES;
SQL

mariadb -u mangos -pmangos pfquest < "$PFQUEST/toolbox/client-data.sql"
mariadb -u mangos -pmangos vmangos < "$MANGOS_SQL"

for file in "$VMANGOS"/sql/migrations/*_world.sql; do
  mariadb -u mangos -pmangos vmangos < "$file"
done

mariadb -u mangos -pmangos vmangos <<'SQL'
ALTER TABLE locales_creature ADD COLUMN IF NOT EXISTS name_loc10 varchar(100);
ALTER TABLE locales_creature ADD COLUMN IF NOT EXISTS subname_loc10 varchar(100);
ALTER TABLE locales_gameobject ADD COLUMN IF NOT EXISTS name_loc10 varchar(100);
ALTER TABLE locales_item ADD COLUMN IF NOT EXISTS name_loc10 varchar(100);
ALTER TABLE locales_item ADD COLUMN IF NOT EXISTS description_loc10 varchar(255);
ALTER TABLE locales_quest ADD COLUMN IF NOT EXISTS Title_loc10 TEXT;
ALTER TABLE locales_quest ADD COLUMN IF NOT EXISTS Details_loc10 TEXT;
ALTER TABLE locales_quest ADD COLUMN IF NOT EXISTS Objectives_loc10 TEXT;
ALTER TABLE locales_quest ADD COLUMN IF NOT EXISTS ObjectiveText1_loc10 TEXT;
ALTER TABLE locales_quest ADD COLUMN IF NOT EXISTS ObjectiveText2_loc10 TEXT;
ALTER TABLE locales_quest ADD COLUMN IF NOT EXISTS ObjectiveText3_loc10 TEXT;
ALTER TABLE locales_quest ADD COLUMN IF NOT EXISTS ObjectiveText4_loc10 TEXT;
ALTER TABLE locales_quest ADD COLUMN IF NOT EXISTS OfferRewardText_loc10 TEXT;
ALTER TABLE locales_quest ADD COLUMN IF NOT EXISTS RequestItemsText_loc10 TEXT;
ALTER TABLE locales_quest ADD COLUMN IF NOT EXISTS EndText_loc10 TEXT;
SQL

PTBR="$WORK/ptBR"
cp -R "$VMANGOS/sql/translations/ptBR" "$PTBR"

for file in "$PTBR"/*.sql; do
  sed -i \
    -e 's/`name`/`name_loc10`/g' \
    -e 's/`subname`/`subname_loc10`/g' \
    -e 's/`description`/`description_loc10`/g' \
    -e 's/`Title`/`Title_loc10`/g' \
    -e 's/`Details`/`Details_loc10`/g' \
    -e 's/`Objectives`/`Objectives_loc10`/g' \
    -e 's/`ObjectiveText1`/`ObjectiveText1_loc10`/g' \
    -e 's/`ObjectiveText2`/`ObjectiveText2_loc10`/g' \
    -e 's/`ObjectiveText3`/`ObjectiveText3_loc10`/g' \
    -e 's/`ObjectiveText4`/`ObjectiveText4_loc10`/g' \
    -e 's/`OfferRewardText`/`OfferRewardText_loc10`/g' \
    -e 's/`RequestItemsText`/`RequestItemsText_loc10`/g' \
    -e 's/`EndText`/`EndText_loc10`/g' \
    "$file"
done

sed -i 's/`creature_template`/`locales_creature`/g' "$PTBR/creature_template.sql"
sed -i 's/`gameobject_template`/`locales_gameobject`/g' "$PTBR/gameobject_template.sql"
sed -i 's/`item_template`/`locales_item`/g' "$PTBR/item_template.sql"
sed -i 's/`quest_template`/`locales_quest`/g' "$PTBR/quest_template.sql"

for file in creature_template.sql gameobject_template.sql item_template.sql quest_template.sql; do
  mariadb -u mangos -pmangos vmangos < "$PTBR/$file"
done

python3 "$ROOT/tools/patch_extractor.py" "$PFQUEST/toolbox/extractor.lua"

(
  cd "$PFQUEST/toolbox"
  rm -rf output
  lua5.3 ./extractor.lua
)

python3 "$ROOT/tools/package_db.py" \
  --source "$PFQUEST/toolbox/output" \
  --repo-root "$ROOT" \
  --overwrites "$PFQUEST/overwrites.lua" \
  --vmangos-release "$VMANGOS_RELEASE" \
  --vmangos-asset "$ASSET_NAME" \
  --vmangos-snapshot "$VMANGOS_SNAPSHOT" \
  --vmangos-core "$VMANGOS_CORE_COMMIT" \
  --pfquest-commit "$PFQUEST_COMMIT"

python3 "$ROOT/tools/validate_generated.py" "$ROOT"

rm -rf "$WORK"
