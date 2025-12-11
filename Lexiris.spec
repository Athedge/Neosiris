# -*- mode: python ; coding: utf-8 -*-


a = Analysis(
    ['src\\Lexiris\\main.py'],
    pathex=[],
    binaries=[('C:\\Program Files\\Tesseract-OCR\\tesseract.exe', 'Tesseract-OCR')],
    datas=[('assets\\Lexiris.png', 'assets'), ('assets\\Lexiris.ico', 'assets'), ('C:\\Program Files\\Tesseract-OCR\\tessdata', 'tessdata')],
    hiddenimports=[],
    hookspath=[],
    hooksconfig={},
    runtime_hooks=[],
    excludes=[],
    noarchive=False,
    optimize=0,
)
pyz = PYZ(a.pure)

exe = EXE(
    pyz,
    a.scripts,
    a.binaries,
    a.datas,
    [],
    name='Lexiris',
    debug=False,
    bootloader_ignore_signals=False,
    strip=False,
    upx=True,
    upx_exclude=[],
    runtime_tmpdir=None,
    console=False,
    disable_windowed_traceback=False,
    argv_emulation=False,
    target_arch=None,
    codesign_identity=None,
    entitlements_file=None,
    icon=['assets\\Lexiris.ico'],
)
