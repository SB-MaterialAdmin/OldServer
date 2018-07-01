/**
 * Этот файл является частью SourceBans Material Admin.
 *
 * Все права принадлежат:
 * -> 2007-2014 SteamFriends, InterWave Studios and GameConnect
 * -> 2014-2016 SourceBans++ Dev Team <https://github.com/sbpp>
 * -> 2016-2018 Material Admin Dev Team <https://github.com/SB-MaterialAdmin>
 *
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program.  If not, see http://www.gnu.org/licenses/
 *
 * Any contact addresses you can found on <https://kruzya.me/>
 */

#include <sourcemod>
#include <sourcebans>

// We support oldest SourceMod versions, so... We don't use "newdecls" pragma.
#pragma semicolon 1

#define SET_BIT(%0,%1)    %0 |= (1 << %1)
#define UNSET_BIT(%0,%1)  %0 &= ~(1 << %1)
#define TOGGLE_BIT(%0,%1) %0 ^= (1 << %1)

#define CHECK_BIT(%0,%1)  %0 & (1 << %1) == (1 << %1)

public Plugin:myinfo = {
  description = "Admin Loader for SB Material Admin",
  version     = "1.0",
  author      = "CrazyHackGUT aka Kruzya",
  name        = "[SB MA] Admin Loader",
  url         = "https://kruzya.me/go?token=54ea46fa5ef52f49d874228bcfac907b"
};

#define OVERRIDES_BIT   1
#define ADMINS_BIT      2
#define GROUPS_BIT      3

new g_iLoadBits = 0;
new g_iReadBits = 0;

public OnPluginStart() {
  FileSystem_Init();
}

public OnRebuildAdminCache(AdminCachePart:ePart) {
  switch (ePart) {
    case AdminCache_Overrides:  SET_BIT(g_iLoadBits, OVERRIDES_BIT),  SET_BIT(g_iReadBits, OVERRIDES_BIT);
    case AdminCache_Groups:     SET_BIT(g_iLoadBits, GROUPS_BIT),     SET_BIT(g_iReadBits, GROUPS_BIT);
    case AdminCache_Admins:     SET_BIT(g_iLoadBits, ADMINS_BIT),     SET_BIT(g_iReadBits, ADMINS_BIT);
  }

  new Handle:hDB = SourceBans_GetDB();
  if (hDB == INVALID_HANDLE)
    ReadCache();
  else
    UpdateCache(hDB);
}

#include "admloader/filesystem.sp"
#include "admloader/database.sp"

ReadCache() {
  if (CHECK_BIT(g_iReadBits, OVERRIDES_BIT))
    ReadCache_Overrides();

  if (CHECK_BIT(g_iReadBits, GROUPS_BIT))
    ReadCache_Groups();

  if (CHECK_BIT(g_iReadBits, ADMINS_BIT))
    ReadCache_Admins();
}

#define SafeReadFileCell(%0,%1,%2,%3)   if (ReadFileCell(%0, %1, %2) < 0) { LogError(%3); FileSystem_Done(); return; }
ReadCache_Overrides() {
  if (!FileSystem_Open(false, OVERRIDES)) {
    LogError("[FS] Can't read Overrides cache.");
    FileSystem_Done();
    return;
  }

  if (!FileSystem_Verify(OVERRIDES)) {
    LogError("[FS] Invalid Overrides cache file.");
    FileSystem_Done();
    return;
  }

  new iOverridesCount;
  new Handle:hFile = FileSystem();

  if (ReadFileCell(hFile, iOverridesCount, 4) < 1) {
    LogError("[FS] Can't read overrides count.");
    FileSystem_Done();
    return;
  }

  new iOverrideNameLength;
  new String:szOverrideName[256];
  new OverrideType:iOverrideType;
  new iOverrideFlags;

  for (new iOverrideID = 0; iOverrideID < iOverridesCount; ++iOverrideID) {
    SafeReadFileCell(hFile, iOverrideNameLength, 4, "[FS] Can't read override name length.")
    ReadFileString(hFile, szOverrideName, sizeof(szOverrideName), iOverrideNameLength);
    SafeReadFileCell(hFile, iOverrideType, 1, "[FS] Can't read override type.")
    SafeReadFileCell(hFile, iOverrideFlags, 4, "[FS] Can't read override flags.")

    AddCommandOverride(szOverrideName, iOverrideType, iOverrideFlags);
  }

  FileSystem_Done();
}

/**
 * About file structure:
 *
 * All files contains this:
 * -> HEADER (SBMA)
 * -> FILETYPE (0, 1, 2)
 *
 * Other content can be:
 * -> ADMINS (type 0)
 * ---> ADMIN_COUNT
 * ---> ADMIN_ENTRIES
 * -----> AID
 * -----> NAME_LENGTH
 * -----> NAME
 * -----> IMMUNITY
 * -----> FLAGS (bits)
 * -----> GROUP_LENGTH
 * -----> GROUP_NAME (if 0 - empty, and don't should be readen)
 * -----> EXPIRES
 *
 * -> GROUPS (type 1)
 * ---> GROUP_COUNT
 * ---> GROUP_ENTRIES
 * -----> NAME_LENGTH
 * -----> NAME
 * -----> IMMUNITY
 * -----> FLAGS (bits)
 * -----> OVERRIDES_COUNT
 * -----> OVERRIDES_ENTRIES
 * -------> NAME_LENGTH
 * -------> NAME
 * -------> OVERRIDE_TYPE (0, 1)
 * -------> OVERRIDE_RULE (0, 1)
 *
 * -> OVERRIDES (type 2)
 * ---> OVERRIDE_COUNT
 * ---> OVERRIDE_ENTRIES
 * -----> NAME_LENGTH
 * -----> NAME
 * -----> OVERRIDE_TYPE (0, 1)
 * -----> FLAGS (bits)
 */
