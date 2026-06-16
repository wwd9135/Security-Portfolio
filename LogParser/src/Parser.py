import xml.etree.ElementTree as ET
from dataclasses import dataclass, asdict
from datetime import datetime
import logging

@dataclass(frozen=True)
class EventRecord:
    event_id: int
    timestamp: str
    message: str

class LogParser:
    def __init__(self):
        self.ns = {"ev": "http://schemas.microsoft.com/win/2004/08/events/event"}
        self.records = []
        self.success_count = 0
        self.error_count = 0

    def parse(self, filename: str, since_str: str = None, target_ids: list = None):
        cutoff_date = None
        if since_str:
            cutoff_date = datetime.strptime(since_str, "%Y-%m-%d %H:%M")

        tree = ET.parse(filename)
        root = tree.getroot()

        for event in root.findall(".//ev:Event", self.ns):
            system = event.find("ev:System", self.ns)
            
            # 1. Event ID Filtering
            event_id = int(system.find("ev:EventID", self.ns).text)
            if target_ids and event_id not in target_ids:
                continue

            # 2. Timestamp Filtering
            ts_str = system.find("ev:TimeCreated", self.ns).attrib.get("SystemTime")
            event_ts = datetime.strptime(ts_str[:19], "%Y-%m-%dT%H:%M:%S")
            if cutoff_date and event_ts < cutoff_date:
                continue

            # Data Normalization
            msg_element = event.find(".//ev:Data", self.ns)
            msg = msg_element.text if msg_element is not None else "N/A"

            record = EventRecord(event_id=event_id, timestamp=ts_str, message=msg)
            self.records.append(asdict(record))

            if "successfully" in msg.lower():
                self.success_count += 1
            else:
                self.error_count += 1

        return {
            "summary": {"total": len(self.records), "success": self.success_count, "failed": self.error_count},
            "data": self.records
        }