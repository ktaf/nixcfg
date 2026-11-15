"""Read portable Linux status and cliphist data for the Quickshell UI."""

import json
import os
from pathlib import Path
import re
import shutil
import subprocess
import sys
import time


def run(*args):
    try:
        return subprocess.run(args, capture_output=True, text=True, timeout=3, check=True).stdout.strip()
    except (OSError, subprocess.SubprocessError):
        return ""


def read(path):
    try:
        return Path(path).read_text().strip()
    except OSError:
        return ""


def cpu_sample():
    values = [int(n) for n in read("/proc/stat").splitlines()[0].split()[1:9]]
    return sum(values), values[3] + values[4]


def hardware():
    result = {"brightness": None, "battery": None, "temperature": None}
    for device in sorted(Path("/sys/class/backlight").glob("*")):
        maximum = int(read(device / "max_brightness") or 0)
        if maximum:
            result["brightness"] = round(100 * int(read(device / "brightness") or 0) / maximum)
            break
    batteries = []
    for device in sorted(Path("/sys/class/power_supply").glob("*")):
        if read(device / "type") == "Battery":
            capacity = read(device / "capacity")
            if capacity:
                batteries.append({"name": device.name, "percent": int(capacity), "state": read(device / "status")})
    if batteries:
        result["battery"] = batteries[0]
    # Avoid hard-coding thermal_zone0, BAT0, or an AMD-specific backlight.
    temperatures = []
    for zone in Path("/sys/class/thermal").glob("thermal_zone*"):
        value = read(zone / "temp")
        if value.lstrip("-").isdigit() and 0 < int(value) < 150000:
            temperatures.append(int(value) / 1000)
    if temperatures:
        result["temperature"] = round(max(temperatures))
    result["capslock"] = any(read(p) == "1" for p in Path("/sys/class/leds").glob("*::capslock/brightness"))
    result["numlock"] = any(read(p) == "1" for p in Path("/sys/class/leds").glob("*::numlock/brightness"))
    return result


def network_sample(previous):
    devices = run("nmcli", "-t", "-f", "DEVICE,TYPE,STATE", "device").splitlines()
    device = next((row.split(":")[0] for row in devices
                   if row.endswith(":connected") and ":loopback:" not in row), "")
    result = {"network": "Disconnected", "wifi": run("nmcli", "radio", "wifi") == "enabled"}
    counters = {}
    if device:
        address = run("nmcli", "-g", "IP4.ADDRESS", "device", "show", device).splitlines()
        result["network"] = device + (" " + address[0] if address else "")
        now = time.monotonic()
        rx = int(read(f"/sys/class/net/{device}/statistics/rx_bytes") or 0)
        tx = int(read(f"/sys/class/net/{device}/statistics/tx_bytes") or 0)
        counters = {"device": device, "time": now, "rx": rx, "tx": tx}
        if previous.get("device") == device:
            seconds = max(now - previous["time"], 0.01)
            result["network"] += f" ↑{max(0, tx - previous['tx']) / seconds / 1024:.0f} ↓{max(0, rx - previous['rx']) / seconds / 1024:.0f} KiB/s"
    return result, counters


def status():
    previous_cpu = cpu_sample()
    previous_network = {}
    while True:
        current_cpu = cpu_sample()
        elapsed = current_cpu[0] - previous_cpu[0]
        idle = current_cpu[1] - previous_cpu[1]
        memory = dict(re.findall(r"^(\w+):\s+(\d+)", read("/proc/meminfo"), re.MULTILINE))
        disk = shutil.disk_usage("/")
        data = hardware()
        network, previous_network = network_sample(previous_network)
        data.update(network)
        data["cpu"] = round(100 * (elapsed - idle) / elapsed) if elapsed else 0
        data["memory"] = round(100 * (1 - int(memory["MemAvailable"]) / int(memory["MemTotal"])))
        data["disk"] = round(100 * disk.used / disk.total)
        volume = re.search(r"(\d+)%", run("pactl", "get-sink-volume", "@DEFAULT_SINK@"))
        data["volume"] = int(volume[1]) if volume else None
        data["muted"] = run("pactl", "get-sink-mute", "@DEFAULT_SINK@").endswith("yes")
        data["bluetooth"] = "Powered: yes" in run("bluetoothctl", "show")
        try:
            inputs = json.loads(run("swaymsg", "-t", "get_inputs", "-r") or "[]")
            data["layout"] = next((i.get("xkb_active_layout_name", "") for i in inputs if i.get("type") == "keyboard"), "")
        except (ValueError, TypeError):
            data["layout"] = ""
        print(json.dumps(data), flush=True)
        previous_cpu = current_cpu
        time.sleep(3)


def clipboard():
    items = []
    for line in run("cliphist", "list").splitlines()[:200]:
        identifier, separator, label = line.partition("\t")
        if separator and identifier.isdecimal():
            items.append({"id": identifier, "label": label})
    print(json.dumps(items))


def paste(identifier):
    if not identifier.isdecimal():
        raise ValueError("Expected a cliphist numeric identifier")
    # Decode as bytes so image entries survive the round trip.
    decoded = subprocess.run(["cliphist", "decode", identifier], capture_output=True, check=True)
    subprocess.run(["wl-copy"], input=decoded.stdout, check=True)


if __name__ == "__main__":
    os.environ["LC_ALL"] = "C"
    if sys.argv[1:] == ["status"]:
        status()
    elif sys.argv[1:] == ["clipboard"]:
        clipboard()
    elif len(sys.argv) == 3 and sys.argv[1] == "paste":
        paste(sys.argv[2])
    else:
        sys.exit("Usage: quickshell-backend status|clipboard|paste ID")
