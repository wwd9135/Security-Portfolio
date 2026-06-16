# Calls classes subnet & cli to handle functionality cleanly.
import logging
from argparse import ArgumentDefaultsHelpFormatter, ArgumentParser, Namespace
import Modules.Subnet as Subnet
import Modules.cli as cli

logging.basicConfig(level=logging.DEBUG, filename='main.log', filemode='a',
                    format='%(asctime)s - %(levelname)s - %(message)s')
logger = logging.getLogger(__name__)

def main():
    logger.info("Program started")

    logger.debug("Initializing CLI and Subnet modules")
    command_line = cli.CLI(1)
    subnet_module = Subnet.subnet()

    logger.debug("Running CLI.instantiate()")
    Subnets = command_line.instantiate()[1]
    logger.debug(f"Subnets returned: {Subnets}")


    logger.debug("Creating subnet hosts")
    Subnet_Hosts = subnet_module.SubnetCreator(Subnets)
    logger.debug(f"Subnet hosts: {Subnet_Hosts}")

    logger.debug("Running IP addressing")
    FinalOutput = subnet_module.IP_Adddressing(Subnet_Hosts)
    logger.info("Processing complete")
    logger.debug(f"Final output: {FinalOutput}")
    logger.info("Program ended\n" \
    "-------------------------")

main()