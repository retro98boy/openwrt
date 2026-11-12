import hashlib
import importlib.util
import json
from pathlib import Path
import subprocess
import shutil
import tempfile
import unittest


spec = importlib.util.spec_from_file_location("ci_release_files", Path(__file__).parents[1] / "ci-release-files.py")
ci = importlib.util.module_from_spec(spec)
spec.loader.exec_module(ci)


class FirmwareReleaseFilesTest(unittest.TestCase):
    def setUp(self):
        self.tmp = tempfile.TemporaryDirectory()
        self.addCleanup(self.tmp.cleanup)
        self.root = Path(self.tmp.name)
        self.info = self.root / "ci-output/build-info"
        self.info.mkdir(parents=True)
        subprocess.run(["git", "init", "-q", str(self.root)], check=True)
        (self.root / "custom-build").mkdir()
        shutil.copyfile(Path(__file__).parents[1] / "release-files.json", self.root / "custom-build/release-files.json")

    def test_verify_expected_devices(self):
        config = self.root / ".config"
        config.write_text("CONFIG_TARGET_rockchip=y\nCONFIG_TARGET_rockchip_armv8=y\n"
                          "CONFIG_TARGET_MULTI_PROFILE=y\n"
                          "CONFIG_TARGET_DEVICE_rockchip_armv8_DEVICE_smart_am40=y\n"
                          "CONFIG_TARGET_DEVICE_rockchip_armv8_DEVICE_norco_emb-3531=y\n")
        ci.verify(self.root, "rockchip")
        config.write_text(config.read_text().replace("CONFIG_TARGET_DEVICE_rockchip_armv8_DEVICE_smart_am40=y", ""))
        with self.assertRaisesRegex(ValueError, "Expected CONFIG_TARGET_DEVICE"):
            ci.verify(self.root, "rockchip")

    def make_images(self, bad_checksum=False):
        output = self.root / "bin/targets/x86/64"
        output.mkdir(parents=True)
        data = b"test firmware\n"
        name = "openwrt-x86-64-generic-squashfs-combined-efi.img.gz"
        (output / name).write_bytes(data)
        images = [{"name": name, "sha256": "bad" if bad_checksum else hashlib.sha256(data).hexdigest()}]
        ci.write_json(output / "profiles.json", {"profiles": {"generic": {"images": images}}})
        for metadata in ["config.buildinfo", "feeds.buildinfo", "version.buildinfo", "sha256sums"]:
            (output / metadata).write_text("test\n")
        (self.root / "feeds").mkdir()
        subprocess.run(["git", "-C", str(self.root), "add", "bin"], check=True)
        subprocess.run(["git", "-C", str(self.root), "-c", "user.name=Test", "-c",
                        "user.email=test@example.com", "commit", "-qm", "test"], check=True)
        return name

    def test_collect_only_configured_assets_and_keep_metadata_separate(self):
        name = self.make_images()
        ci.collect(self.root, "x86-64-efi-qemu", self.info)
        release = self.root / "ci-output/release"
        self.assertEqual([p.name for p in release.iterdir()], [name])
        self.assertTrue((self.info / "build.json").is_file())
        self.assertEqual(json.loads((self.info / "release-files.json").read_text())[0]["name"], name)

    def test_missing_configured_asset_fails(self):
        self.make_images()
        manifest = self.root / "custom-build/release-files.json"
        data = json.loads(manifest.read_text())
        data["x86-64-efi-qemu"].append("bin/targets/x86/64/missing.bin")
        ci.write_json(manifest, data)
        with self.assertRaisesRegex(ValueError, "exactly one"):
            ci.collect(self.root, "x86-64-efi-qemu", self.info)

    def test_collect_refuses_bad_image_checksum(self):
        self.make_images(bad_checksum=True)
        with self.assertRaisesRegex(ValueError, "checksum mismatch"):
            ci.collect(self.root, "x86-64-efi-qemu", self.info)


if __name__ == "__main__":
    unittest.main()
