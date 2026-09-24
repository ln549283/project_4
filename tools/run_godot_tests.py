#!/usr/bin/env python3
"""Fail on script errors even when Godot's process exit status is zero."""
import os,subprocess,sys
from pathlib import Path
root=Path(__file__).resolve().parents[1]
godot=sys.argv[1] if len(sys.argv)>1 else 'godot'
failed=[]
for test in sorted((root/'tests').rglob('*test.gd')):
 rel=test.relative_to(root)
 try:
  result=subprocess.run([godot,'--headless','--path',str(root),'--script',str(rel)],capture_output=True,text=True,timeout=45,cwd=root)
 except subprocess.TimeoutExpired:
  failed.append(str(rel));print('TIMEOUT',rel,flush=True);continue
 log=result.stdout+result.stderr
 bad=result.returncode!=0 or 'SCRIPT ERROR:' in log or 'Failed to load script' in log
 print(('FAIL' if bad else 'PASS'),rel,flush=True)
 if bad:
  failed.append(str(rel));print(log,flush=True)
if failed:sys.exit(1)
print('All Godot suites passed without script errors.')
