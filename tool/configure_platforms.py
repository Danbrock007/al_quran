"""Apply required native permissions after `flutter create` generates platforms."""
from pathlib import Path


def patch_android() -> None:
    path = Path("android/app/src/main/AndroidManifest.xml")
    text = path.read_text(encoding="utf-8")
    marker = "<application"
    permissions = """<uses-permission android:name="android.permission.INTERNET"/>
    <uses-permission android:name="android.permission.ACCESS_FINE_LOCATION"/>
    <uses-permission android:name="android.permission.ACCESS_COARSE_LOCATION"/>
    <uses-permission android:name="android.permission.POST_NOTIFICATIONS"/>
    <uses-permission android:name="android.permission.SCHEDULE_EXACT_ALARM"/>
    <uses-permission android:name="android.permission.VIBRATE"/>
    """
    if "ACCESS_FINE_LOCATION" not in text:
        text = text.replace(marker, permissions + marker, 1)
    text = text.replace('android:label="al_quran"', 'android:label="Al-Quran"')
    path.write_text(text, encoding="utf-8")


def patch_ios() -> None:
    path = Path("ios/Runner/Info.plist")
    text = path.read_text(encoding="utf-8")
    addition = """\t<key>NSLocationWhenInUseUsageDescription</key>
\t<string>Al-Quran uses your location for prayer times and Qibla direction.</string>
\t<key>UIBackgroundModes</key>
\t<array>
\t\t<string>audio</string>
\t</array>
"""
    if "NSLocationWhenInUseUsageDescription" not in text:
        text = text.replace("</dict>", addition + "</dict>", 1)
    path.write_text(text, encoding="utf-8")


if __name__ == "__main__":
    patch_android()
    patch_ios()

