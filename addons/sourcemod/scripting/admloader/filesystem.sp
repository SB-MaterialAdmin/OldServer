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

// File Cache Worker
static stock String:g_szHeader[]  = "AMBS";

new Handle:g_hFile = INVALID_HANDLE;
new g_iOpenId;

new String:g_szPath[3][256];

#define INVALID   -1
#define ADMINS    0
#define GROUPS    1
#define OVERRIDES 2

FileSystem_Init() {
  BuildPath(Path_SM, g_szPath[ADMINS],    sizeof(g_szPath[]), "data/sbma_cache/admins.dat");
  BuildPath(Path_SM, g_szPath[GROUPS],    sizeof(g_szPath[]), "data/sbma_cache/groups.dat");
  BuildPath(Path_SM, g_szPath[OVERRIDES], sizeof(g_szPath[]), "data/sbma_cache/overrides.dat");
}

bool:FileSystem_Open(bool:bWrite = false, iId = 0) {
  g_hFile = OpenFile(g_szPath[iId], bWrite ? "wb" : "rb");
  g_iOpenId = iId;

  return FileSystem_Ok();
}

FileSystem_Done() {
  CloseHandle(g_hFile);
  g_hFile = INVALID_HANDLE;
}

bool:FileSystem_Ok() {
  return g_hFile != INVALID_HANDLE;
}

FileSystem_ID() {
  if (FileSystem_Ok())
    return g_iOpenId;
  return -1;
}

Handle:FileSystem() {
  return g_hFile;
}

bool:FileSystem_Verify(iId = 0) {
  new String:header[8];

  FileSeek(FileSystem(), 0, SEEK_SET);
  ReadFileString(FileSystem(), header, sizeof(header), 4);

  if (strcmp(header, g_szHeader, true)) {
    LogError("[FS | Core] Verify failed: Invalid header.");
    return false;
  }

  new dummy;
  if (ReadFileCell(FileSystem(), dummy, 1) < 1) {
    LogError("[FS | Core] Can't read file type.");
    return false;
  }

  return (dummy == iId);
}