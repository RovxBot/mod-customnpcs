#!/usr/bin/env python3
"""Run syntax-only checks against an existing core checkout; never configure/build worldserver."""
import argparse
from pathlib import Path
import subprocess

ROOT=Path(__file__).resolve().parents[1]


def main():
    parser=argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--core-root',type=Path,required=True);parser.add_argument('--boost-root',type=Path)
    parser.add_argument('--extra-include',type=Path,action='append',default=[])
    parser.add_argument('--compiler',default='clang++');parser.add_argument('sources',nargs='+',type=Path);args=parser.parse_args()
    core=args.core_root
    roots=[core/'src/common',core/'src/server/game',core/'src/server/shared',core/'src/server/database']
    include=[ROOT/'src',core/'src/server',core/'deps']
    for root in roots:
        include += [root]+[p for p in root.rglob('*') if p.is_dir()]
    include += [core/'deps'/p for p in ['fmt/include','g3dlite/include','recastnavigation/Detour/Include','SFMT','utf8cpp']]
    if args.boost_root:include.insert(0,args.boost_root)
    include=args.extra_include+include
    command=[args.compiler,'-std=c++20','-fsyntax-only','-Wall','-Wextra','-Werror','-DACORE_API_USE_DYNAMIC_LINKING=0']
    for path in include:command+=['-I',str(path)]
    for source in args.sources:
        subprocess.run([*command,str(source)],check=True);print('Syntax checked:',source,flush=True)


if __name__=='__main__':main()
