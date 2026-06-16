import logging

logging.basicConfig(level=logging.DEBUG, filename='main.log', filemode='a',
                    format='%(asctime)s - %(levelname)s - %(message)s')
logger = logging.getLogger(__name__)

from argparse import Namespace, ArgumentParser
import re
import os

class CLI:
    def __init__(self, verboseC):
        self.verboseCount = verboseC

    def instantiate(self):
        parser = ArgumentParser()
        parser.usage = (
            "Example input: Subnet name: Host count(integer value) : "
            "Marketing:43/IT:54/HR:90 [-h] fileName.txt"
        )
        parser.add_argument(
            "Subnet",
            help="Enter a Subnet name, colon, then host count...",
            type=str
        )

        arg: Namespace = parser.parse_args()
        result: str = arg.Subnet

        for i in result.split("/"):
            if not re.match(r"^[A-Za-z]+:\d+$", i):
                print(
                    f"Invalid subnet entry: {i}. "
                    "Please use the format 'SubnetName:HostCount/...'"
                )
                logger.error(f"Invalid subnet entry: {i}")   # <— logs to main.log
                os._exit(1)

        dict_result = {
            key: int(value)
            for key, value in (item.split(":") for item in result.split("/"))
        }

        logger.debug(f"Parsed subnet dictionary: {dict_result}")
        return arg, dict_result
