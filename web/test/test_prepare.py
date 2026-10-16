from pathlib import Path
import sys
from tempfile import TemporaryDirectory
import unittest

sys.path.insert(0, str(Path(__file__).resolve().parents[1] / "scripts"))
from prepare import copy_tree


class CopyTreeTests(unittest.TestCase):
    def test_preserve_runtime_test_modules_in_packages(self):
        with TemporaryDirectory() as temporary:
            root = Path(temporary)
            source = root / "source"
            source.mkdir()
            (source / "test.typ").write_text("#let is-empty = ()")
            (source / "exercice.typ").write_text("#let ex = ()")
            (source / "test.ml").write_text("let () = ()")
            self.assertEqual(copy_tree(source, root / "bank"), ["exercice.typ"])
            self.assertIn("test.typ", copy_tree(source, root / "package", exclude_tests=False))

    def test_preserve_wasm_plugins_in_packages(self):
        with TemporaryDirectory() as temporary:
            root = Path(temporary)
            source = root / "source"
            (source / "dist").mkdir(parents=True)
            wasm = b"\0asm\x01\0\0\0"
            (source / "dist/code-extract.wasm").write_bytes(wasm)
            self.assertEqual(copy_tree(source, root / "package", exclude_tests=False), ["dist/code-extract.wasm"])
            self.assertEqual((root / "package/dist/code-extract.wasm").read_bytes(), wasm)

    def test_reject_files_outside_public_root(self):
        with TemporaryDirectory() as temporary:
            root = Path(temporary)
            source = root / "source"
            source.mkdir()
            private = root / "private.txt"
            private.write_text("fictif")
            (source / "outside.txt").symlink_to(private)
            with self.assertRaisesRegex(ValueError, "hors de la banque"):
                copy_tree(source, root / "destination")


if __name__ == "__main__":
    unittest.main()
