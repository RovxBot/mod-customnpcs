#
# This file is part of the AzerothCore Project. See AUTHORS file for Copyright information
#
# This program is free software; you can redistribute it and/or modify it
# under the terms of the GNU Affero General Public License as published by the
# Free Software Foundation; either version 3 of the License, or (at your
# option) any later version.
#
# This program is distributed in the hope that it will be useful, but WITHOUT
# ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or
# FITNESS FOR A PARTICULAR PURPOSE. See the GNU Affero General Public License for
# more details.
#
# You should have received a copy of the GNU General Public License along
# with this program. If not, see <http://www.gnu.org/licenses/>.
#

set(MOD_CUSTOMNPCS_SOURCE_DIR ${CMAKE_CURRENT_LIST_DIR}/src)

if(COMMAND CollectSourceFiles)
  CollectSourceFiles(
    ${MOD_CUSTOMNPCS_SOURCE_DIR}
    PRIVATE_SOURCES
  )

  if (USE_SCRIPTPCH)
    set(PRIVATE_PCH_HEADER ${MOD_CUSTOMNPCS_SOURCE_DIR}/mod_customnpcs_pch.h)
  endif()

  AddModuleSourceFiles(PRIVATE_SOURCES)

  if(COMMAND AddModulesScriptLoader)
    AddModulesScriptLoader("ModCustomNPCs" "void AddModCustomNPCsScripts()")
  endif()

  if(PRIVATE_SOURCES)
    CreateModuleScript("mod-customnpcs" PRIVATE_SOURCES)
  endif()
elseif(COMMAND CU_AC_ADD_SCRIPT)
  CU_AC_ADD_SCRIPT("${MOD_CUSTOMNPCS_SOURCE_DIR}" SKIP_BATCHING)
else()
  message(FATAL_ERROR "Unsupported AzerothCore CMake API for mod-customnpcs")
endif()
