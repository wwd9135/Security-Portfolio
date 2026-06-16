import xml.etree.ElementTree as ET
from dataclasses import dataclass, field
import logging


logging.basicConfig(
    level=logging.DEBUG,
    filename='main.log',
    filemode='a',
    format='%(asctime)s - %(levelname)s - %(message)s'
)

@dataclass
class DataClass:
    eventId: int
    TimeStamp: str
    Message: str
    SuccessCount: int = 0
    ErrorCount: int = 0
    VerboseDictionary: list = field(default_factory=list)

    logger = logging.getLogger(__name__)

    def __post_init__(self):
        # Validate input properly
        if self.eventId is None or self.TimeStamp is None or self.Message is None:
            self.logger.error(
                "Missing input parameters, potentially bad XML format or corrupted data."
            )
            raise ValueError("Missing values, potentially bad XML input.")

        # Store structured data (ACTUAL dicts)
        entry = {
            "EventID": self.eventId,
            "TimeStamp": self.TimeStamp,
            "Message": self.Message
        }
        self.VerboseDictionary.append(entry)

        # Count success / error
        if "successfully" in self.Message.lower():
            self.SuccessCount += 1
        else:
            self.ErrorCount += 1

        if self.SuccessCount == 0 and self.ErrorCount == 0:
            self.logger.debug("No success or error messages found")

        self.logger.info("Parser closing, input validated successfully")
class Parser:
    def __init__(self):
        self.logName = "Pslog.xml"

    def parse1(self):
        logger = logging.getLogger(__name__)
        try:
            tree = ET.parse("src/MyTestLog.xml")
            root = tree.getroot()
            logger.info("Parse module started: XML content readable")
        except Exception as e:
            logger.error("Data missing or unloadable from xml file")
            raise ValueError(f"Content not loading from log.xml file: {e}")

        ns = {"ev": "http://schemas.microsoft.com/win/2004/08/events/event"}
        lst = []
        for event in root.findall(".//ev:Event", ns):
            system = event.find("ev:System", ns)
            eventdata = event.find("ev:EventData", ns)

            event_id = int(system.find("ev:EventID", ns).text)
            timestamp = system.find("ev:TimeCreated", ns).attrib.get("SystemTime")

            data_elem = eventdata.find("ev:Data", ns)
            message = data_elem.text if data_elem is not None else None

            lst.append( DataClass(
                eventId=event_id,
                TimeStamp=timestamp,
                Message=message
            ));
        VerboseDict = []
        successC = []
        ErrorC = []
        for i in lst:
            VerboseDict.append(i.VerboseDictionary)
            successC.append(i.SuccessCount)
            ErrorC.append(i.ErrorCount)
        final = [VerboseDict,successC,ErrorC]
        return final
